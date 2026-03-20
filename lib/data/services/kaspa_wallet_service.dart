import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';

import 'kaspa_signing.dart';

// ─── Kaspa transaction mass calculation ───────────────────────────────────────
// Reference: rusty-kaspa wallet/core/src/tx/generator/generator.rs
//            rusty-kaspa wallet/core/src/tx/mass.rs
//
// Consensus parameters (mainnet & testnet-10):
//   mass_per_tx_byte              = 1
//   mass_per_script_pub_key_byte  = 10
//   mass_per_sig_op               = 1000
//   STORAGE_MASS_PARAMETER  C     = 10^12 (KIP-0009)
//   MINIMUM_RELAY_FEE             = 1 sompi/gram
//
// Standard P2PK sizes (verified against node responses):
//   sig_script = 66 bytes  (OP_DATA_65 + 64-byte Schnorr sig + SIG_HASH_ALL)
//   SPK script = 34 bytes  (OP_DATA_32 + 32-byte x-only pubkey + OP_CHECKSIG)
//
// Cross-checked:  1 input + 2 outputs → mass 2036  ✓
//                10 inputs + 1 output  → mass 11686 ✓

const _kStorageC = 1000000000000; // STORAGE_MASS_PARAMETER = 10^12

/// Serialized byte size of a standard P2PK transaction with [n] inputs and [m] outputs.
///   base     = 94  (version u16 + n_inputs u64 + n_outputs u64 + locktime u64
///                   + subnetwork_id 20B + gas u64 + payload_hash 32B + payload_len u64)
///   input    = 118 (outpoint 36B + sig_script_len u64 + sig_script 66B + sequence u64)
///   output   = 52  (value u64 + spk_version u16 + spk_len u64 + spk_script 34B)
int _p2pkTxSize(int n, int m) => 94 + 118 * n + 52 * m;

/// Compute mass.
///   size × mass_per_tx_byte(1)
/// + Σ_outputs (spk_version(2) + spk_script(34)) × mass_per_spk_byte(10) = 360 per output
/// + Σ_inputs  sig_op_count(1) × mass_per_sig_op(1000) = 1000 per input
int _computeMass(int n, int m) {
  final size = _p2pkTxSize(n, m);
  return size + 360 * m + 1000 * n;
}

/// Storage mass for given inputs and an output harmonic (KIP-0009).
/// Uses the wallet generator's arithmetic-mean formula for the input deduction:
///   input_deduction = N × (C / mean_input) = N² × C / total_input
///   storage_mass    = max(0, output_harmonic − input_deduction)
/// This is a conservative overestimate vs. the consensus harmonic-sum formula,
/// which ensures fee estimates are never too low.
int _storageMassFromHarmonic(List<int> ins, int outputHarmonic) {
  final n = ins.length;
  if (n == 0) return outputHarmonic;
  final totalIn = ins.fold<int>(0, (s, a) => s + a);
  if (totalIn == 0) return outputHarmonic;
  // arithmetic mean: N × (C / (total/N)) = N² × C / total
  final harmIn = n * (_kStorageC ~/ (totalIn ~/ n));
  final diff = outputHarmonic - harmIn;
  return diff > 0 ? diff : 0;
}

/// Whether a P2PK output value is dust (below relay threshold).
/// Formula from mass.rs is_transaction_output_dust():
///   total_serialized_size = output_size(52) + redeem_input_size(148) = 200
///   dust iff: value × 1000 / (3 × 200) < 1000  →  value < 600 sompi
bool _isDust(int value) => value < 600;

/// Mass disposition for a final transaction.
/// Mirrors rusty-kaspa generator.rs calculate_mass() logic.
/// Returns the storage mass to use and whether to absorb change into fees.
///
/// [ins]            – input amounts in sompi
/// [changeEstimate] – total_input − send_amount (before network fees, per rusty-kaspa)
/// [recipientHarmonic] – C / recipient_amount (pre-computed)
/// [computeWithChange] – compute mass assuming 2 outputs
({int storageMass, bool absorb}) _massDisposition(
  List<int> ins,
  int changeEstimate,
  int recipientHarmonic,
  int computeWithChange,
) {
  // dust → always absorb
  if (_isDust(changeEstimate)) {
    return (
      storageMass: _storageMassFromHarmonic(ins, recipientHarmonic),
      absorb: true,
    );
  }

  final smWithChange = _storageMassFromHarmonic(
    ins,
    recipientHarmonic + _kStorageC ~/ changeEstimate,
  );

  // If storage mass is dominated by compute mass, no penalty
  if (smWithChange == 0 || smWithChange < computeWithChange) {
    return (storageMass: 0, absorb: false);
  }

  final smNoChange = _storageMassFromHarmonic(ins, recipientHarmonic);

  if (smWithChange < smNoChange) {
    // change output actually helps (unusual — e.g. rebalancing)
    return (storageMass: smWithChange, absorb: false);
  }

  // If the extra fee from keeping change > change value → absorb
  final diff =
      smWithChange > smNoChange ? smWithChange - smNoChange : 0;
  if (diff > changeEstimate) {
    return (storageMass: smNoChange, absorb: true);
  }

  return (storageMass: smWithChange, absorb: false);
}

/// Pure-Dart implementation of Kaspa wallet operations.
class KaspaWalletService {
  // Kaspa cashaddr charset (same as bech32/cashaddr base-32)
  static const String _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';

  // ---------------------------------------------------------------------------
  // BIP39 — mnemonic generation and validation
  // ---------------------------------------------------------------------------

  /// Generates a new BIP39 mnemonic with [wordCount] words (12 or 24).
  String generateMnemonic({int wordCount = 12}) {
    final strength = wordCount == 24 ? 256 : 128;
    return bip39.generateMnemonic(strength: strength);
  }

  /// Validates a BIP39 mnemonic phrase.
  ({bool valid, String error}) validateMnemonic(String phrase) {
    final words =
        phrase.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    if (words.length != 12 && words.length != 24) {
      return (
        valid: false,
        error: 'InvalidWordCount: must be 12 or 24 words, got ${words.length}',
      );
    }

    if (!bip39.validateMnemonic(phrase.trim())) {
      final wordRe = RegExp(r'^[a-z]+$');
      for (final w in words) {
        if (!wordRe.hasMatch(w)) {
          return (
            valid: false,
            error: 'InvalidWord: "$w" is not in the BIP39 word list',
          );
        }
      }
      return (
        valid: false,
        error: 'InvalidChecksum: mnemonic checksum verification failed',
      );
    }

    return (valid: true, error: '');
  }

  // ---------------------------------------------------------------------------
  // BIP32 — Kaspa address derivation  (m/44'/111111'/0'/0/0)
  // ---------------------------------------------------------------------------

  /// Derives the primary Kaspa address from a BIP39 mnemonic.
  /// Path: m/44'/111111'/0'/0/0  (Kaspa coin type 111111)
  String deriveAddress(String mnemonic, {String hrp = 'kaspa'}) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/111111'/0'/0/0");
    return _encodeKaspaAddress(child.publicKey, hrp: hrp);
  }

  // ---------------------------------------------------------------------------
  // Transaction submission — signed P2PK Schnorr transaction via wRPC
  // ---------------------------------------------------------------------------

  Future<({String txId, String error})> sendTransaction({
    required String mnemonic,
    required String toAddress,
    required int amountSompi,
    required String payloadNote,
    required String activeUrl,
    String hrp = 'kaspa',
  }) async {
    // Derive sending key and address
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/111111'/0'/0/0");
    final ourAddress = _encodeKaspaAddress(child.publicKey, hrp: hrp);

    if (!toAddress.startsWith('$hrp:')) {
      return (txId: '', error: 'Destination must be a valid $hrp: address');
    }

    final WebSocket ws;
    try {
      ws = await WebSocket.connect(activeUrl)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      return (txId: '', error: 'WebSocket connect error: $e');
    }

    try {
      const utxoReqId = 1;
      const submitReqId = 2;

      final utxoCompleter = Completer<List<dynamic>>();
      final submitCompleter = Completer<Map<String, dynamic>>();

      final sub = ws.listen(
        (raw) {
          if (raw is! String) return;
          debugPrint('[KaspaWallet] ← $raw');
          try {
            final msg = jsonDecode(raw) as Map<String, dynamic>;
            final id = (msg['id'] as num?)?.toInt();
            if (id == utxoReqId && !utxoCompleter.isCompleted) {
              final entries =
                  (msg['params'] as Map<String, dynamic>?)?['entries']
                      as List<dynamic>? ??
                  [];
              utxoCompleter.complete(entries);
            } else if (id == submitReqId && !submitCompleter.isCompleted) {
              submitCompleter.complete(msg);
            }
          } catch (_) {}
        },
        onError: (Object e) {
          if (!utxoCompleter.isCompleted) utxoCompleter.completeError(e);
          if (!submitCompleter.isCompleted) submitCompleter.completeError(e);
        },
        onDone: () {
          if (!utxoCompleter.isCompleted) utxoCompleter.complete([]);
          if (!submitCompleter.isCompleted) submitCompleter.complete({});
        },
      );

      // ── Step 1: Fetch UTXOs ────────────────────────────────────────────
      ws.add(jsonEncode({
        'id': utxoReqId,
        'method': 'getUtxosByAddresses',
        'params': {'addresses': [ourAddress]},
      }));

      final List<dynamic> utxoEntries;
      try {
        utxoEntries =
            await utxoCompleter.future.timeout(const Duration(seconds: 10));
      } catch (e) {
        await sub.cancel();
        return (txId: '', error: 'UTXO fetch error: $e');
      }

      // ── UTXO selection + fee calculation ──────────────────────────────
      //
      // Mirrors rusty-kaspa wallet/core/src/tx/generator/generator.rs
      //
      // Phase 1 – greedy selection using compute_mass(N,2) as lower bound.
      // Phase 2 – converge fee: storage mass depends on output amounts which
      //           depend on fee; iterate until stable (≤ 5 steps).
      // Phase 3 – extend if Phase 2 raised fees above available funds.
      //
      // Change output decision (mirrors calculate_mass + absorb logic):
      //   changeEstimate = total_input − amount  (before network fees, per rusty-kaspa)
      //   If absorbing change (storage penalty > change value): 1 output, fee absorbs excess.

      final int recipientHarmonic = _kStorageC ~/ amountSompi;

      // Run the mass-disposition convergence for the current input set.
      // Returns (feeSompi, absorbChange).
      ({int fee, bool absorb}) converge(List<int> ins, int total) {
        var fee = _computeMass(ins.length, 2);
        var absorb = false;
        for (var i = 0; i < 5; i++) {
          final changeEst = total - amountSompi; // rusty-kaspa: before fees
          if (changeEst <= 0) {
            absorb = true;
            fee = _computeMass(ins.length, 1);
            break;
          }
          final computeWith = _computeMass(ins.length, 2);
          final (:storageMass, absorb: absorbNow) = _massDisposition(
            ins,
            changeEst,
            recipientHarmonic,
            computeWith,
          );
          absorb = absorbNow;
          final numOut = absorbNow ? 1 : 2;
          final cm = _computeMass(ins.length, numOut);
          final txMass = cm > storageMass ? cm : storageMass;
          if (txMass == fee) break;
          fee = txMass;
        }
        return (fee: fee, absorb: absorb);
      }

      // Phase 1
      final selectedUtxos = <Map<String, dynamic>>[];
      final inputAmounts = <int>[];
      var totalInput = 0;
      for (final entry in utxoEntries) {
        final utxo = entry as Map<String, dynamic>;
        final value = int.tryParse(
              (utxo['utxoEntry'] as Map<String, dynamic>?)?['amount']
                      ?.toString() ??
                  '0',
            ) ??
            0;
        selectedUtxos.add(utxo);
        inputAmounts.add(value);
        totalInput += value;
        if (totalInput >= amountSompi + _computeMass(selectedUtxos.length, 2)) {
          break;
        }
      }

      // Phase 2
      var (:fee, :absorb) = converge(inputAmounts, totalInput);

      // Phase 3: extend if still short
      if (totalInput < amountSompi + fee) {
        for (final entry in utxoEntries.skip(selectedUtxos.length)) {
          final utxo = entry as Map<String, dynamic>;
          final value = int.tryParse(
                (utxo['utxoEntry'] as Map<String, dynamic>?)?['amount']
                        ?.toString() ??
                    '0',
              ) ??
              0;
          selectedUtxos.add(utxo);
          inputAmounts.add(value);
          totalInput += value;
          (fee: fee, absorb: absorb) = converge(inputAmounts, totalInput);
          if (totalInput >= amountSompi + fee) break;
        }
      }

      final feeSompi = fee;
      final absorbChange = absorb;
      final changeSompi = totalInput - amountSompi - feeSompi;

      if (changeSompi < 0) {
        await sub.cancel();
        return (
          txId: '',
          error: 'Insufficient funds: have $totalInput sompi, '
              'need ${amountSompi + feeSompi} sompi',
        );
      }

      const maxStandardMass = 100000;
      if (feeSompi > maxStandardMass) {
        await sub.cancel();
        return (
          txId: '',
          error: 'Transaction mass too high ($feeSompi > $maxStandardMass). '
              'The send amount may be too small relative to your UTXO sizes.',
        );
      }

      // Whether to emit a change output
      // (absorb flag from convergence + guard against dust change)
      final includeChange = !absorbChange && changeSompi > 0 && !_isDust(changeSompi);

      // ── Build output descriptors ───────────────────────────────────────
      final toScript = _addressToP2pkScript(toAddress);
      final ourScript = _addressToP2pkScript(ourAddress);

      final kaspaOutputs = <KaspaOutput>[
        KaspaOutput(
          value: amountSompi,
          scriptVersion: 0,
          script: Uint8List.fromList(HEX.decode(toScript)),
        ),
      ];
      if (includeChange) {
        kaspaOutputs.add(KaspaOutput(
          value: changeSompi,
          scriptVersion: 0,
          script: Uint8List.fromList(HEX.decode(ourScript)),
        ));
      }

      // ── Build input descriptors for signing ───────────────────────────
      final txIds = <String>[];
      final outpointIndices = <int>[];
      final kaspaUtxos = <KaspaUtxo>[];

      for (final entry in selectedUtxos) {
        final outpoint = entry['outpoint'] as Map<String, dynamic>? ?? {};
        final utxoEntry = entry['utxoEntry'] as Map<String, dynamic>? ?? {};
        final spkHex = utxoEntry['scriptPublicKey'] as String? ?? '';
        final (:version, :script) = parseCompactSpk(spkHex);
        final amount =
            int.tryParse(utxoEntry['amount']?.toString() ?? '0') ?? 0;
        txIds.add(outpoint['transactionId'] as String? ?? '');
        outpointIndices.add((outpoint['index'] as num?)?.toInt() ?? 0);
        kaspaUtxos.add(
          KaspaUtxo(amount: amount, scriptVersion: version, script: script),
        );
      }

      // ── Sign each input with BIP340 Schnorr ───────────────────────────
      final signedInputs = <Map<String, dynamic>>[];
      for (var i = 0; i < txIds.length; i++) {
        final sigHash = calcKaspaSigHash(
          txVersion: 0,
          txIds: txIds,
          indices: outpointIndices,
          utxos: kaspaUtxos,
          outputs: kaspaOutputs,
          inputIndex: i,
        );
        final sig64 = kaspaSchnorrSign(child.privateKey!, sigHash);
        final sigScriptHex = HEX.encode(buildP2pkSigScript(sig64));
        signedInputs.add({
          'previousOutpoint': {
            'transactionId': txIds[i],
            'index': outpointIndices[i],
          },
          'signatureScript': sigScriptHex,
          'sequence': 0,
          'sigOpCount': 1,
        });
      }

      // ── Assemble transaction ──────────────────────────────────────────
      final outputs = kaspaOutputs
          .map((o) => {
                'value': o.value,
                'scriptPublicKey': '0000${HEX.encode(o.script)}',
              })
          .toList();

      final transaction = {
        'version': 0,
        'inputs': signedInputs,
        'outputs': outputs,
        'lockTime': 0,
        'subnetworkId': '0000000000000000000000000000000000000000',
        'gas': 0,
        'payload': '',
        'mass': 0,
      };

      // ── Step 2: Submit ────────────────────────────────────────────────
      final submitRequest = jsonEncode({
        'id': submitReqId,
        'method': 'submitTransaction',
        'params': {'transaction': transaction, 'allowOrphan': false},
      });
      debugPrint('[KaspaWallet] → $submitRequest');
      ws.add(submitRequest);

      final Map<String, dynamic> submitResponse;
      try {
        submitResponse = await submitCompleter.future
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        await sub.cancel();
        return (txId: '', error: 'Submit error: $e');
      }

      await sub.cancel();

      if (submitResponse.containsKey('error')) {
        final err = submitResponse['error'];
        final errMsg = err is Map<String, dynamic>
            ? err['message'] as String? ?? 'Unknown error'
            : err.toString();
        return (txId: '', error: errMsg);
      }

      final params = submitResponse['params'] as Map<String, dynamic>?;
      final txId = params?['transactionId'] as String? ?? '';
      if (txId.isNotEmpty) {
        return (txId: txId, error: '');
      }
      return (
        txId: '',
        error: 'Unexpected response: ${jsonEncode(submitResponse)}',
      );
    } finally {
      await ws.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Kaspa cashaddr encoding (custom bech32-like with ':' separator)
  // ---------------------------------------------------------------------------

  static int _polymod(List<int> data) {
    var c = 1;
    for (final d in data) {
      final c0 = c >> 35;
      c = ((c & 0x07ffffffff) << 5) ^ d;
      if (c0 & 0x01 != 0) c ^= 0x98f2bc8e61;
      if (c0 & 0x02 != 0) c ^= 0x79b76d99e2;
      if (c0 & 0x04 != 0) c ^= 0xf33e5fb3c4;
      if (c0 & 0x08 != 0) c ^= 0xae2eabe2a8;
      if (c0 & 0x10 != 0) c ^= 0x1e4f43e470;
    }
    return c ^ 1;
  }

  static List<int> _convertBits(
    List<int> data,
    int fromBits,
    int toBits,
    bool pad,
  ) {
    var acc = 0;
    var bits = 0;
    final result = <int>[];
    final maxv = (1 << toBits) - 1;
    for (final value in data) {
      acc = ((acc << fromBits) | value) & 0xffffffff;
      bits += fromBits;
      while (bits >= toBits) {
        bits -= toBits;
        result.add((acc >> bits) & maxv);
      }
    }
    if (pad && bits > 0) {
      result.add((acc << (toBits - bits)) & maxv);
    }
    return result;
  }

  static String _encodeKaspaAddress(
    Uint8List pubkeyBytes, {
    String hrp = 'kaspa',
  }) {
    final payload = [0x00, ...pubkeyBytes.sublist(1)];
    final data5 = _convertBits(payload, 8, 5, true);
    final checksumInput = [
      ...hrp.codeUnits.map((c) => c & 0x1f),
      0,
      ...data5,
      0, 0, 0, 0, 0, 0, 0, 0,
    ];
    final checksum = _polymod(checksumInput);
    final sb = StringBuffer('$hrp:');
    for (final d in data5) {
      sb.write(_charset[d]);
    }
    for (var i = 7; i >= 0; i--) {
      sb.write(_charset[(checksum >> (i * 5)) & 0x1f]);
    }
    return sb.toString();
  }

  static String _addressToP2pkScript(String address) {
    final colonIdx = address.indexOf(':');
    if (colonIdx < 0) return '';
    final data = address.substring(colonIdx + 1).toLowerCase();
    final charMap = <String, int>{};
    for (var i = 0; i < _charset.length; i++) {
      charMap[_charset[i]] = i;
    }
    final data5 = <int>[];
    for (final c in data.split('')) {
      final val = charMap[c];
      if (val != null) data5.add(val);
    }
    if (data5.length < 9) return '';
    final payload5 = data5.sublist(0, data5.length - 8);
    final payload8 = _convertBits(payload5, 5, 8, false);
    if (payload8.length < 33) return '';
    final pubkey32 = payload8.sublist(1, 33);
    return '20${HEX.encode(pubkey32)}ac';
  }
}
