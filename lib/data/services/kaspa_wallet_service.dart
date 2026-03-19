import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;

/// Pure-Dart implementation of Kaspa wallet operations.
/// Replaces the former rinf/Rust bridge for mnemonic generation, validation,
/// address derivation and transaction submission.
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
  /// Returns `valid: true` on success or `valid: false` with a descriptive
  /// [error] string that the existing `_parseError` logic can classify.
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
      // Heuristic: if any word contains non-lowercase-alpha chars it's likely
      // not in the wordlist; otherwise blame the checksum.
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
  /// [hrp] defaults to 'kaspa' (mainnet); pass 'kaspatest' for testnet-10.
  String deriveAddress(String mnemonic, {String hrp = 'kaspa'}) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/111111'/0'/0/0");
    // child.publicKey is the 33-byte compressed secp256k1 pubkey.
    return _encodeKaspaAddress(child.publicKey, hrp: hrp);
  }

  // ---------------------------------------------------------------------------
  // Transaction submission — replicates the former Rust REST implementation
  // exactly (unsigned tx, signatureScript: "").
  // NOTE: unsigned transactions will not relay on mainnet — this matches the
  // pre-existing Rust behaviour and is tracked as a known bug.
  // ---------------------------------------------------------------------------

  Future<({String txId, String error})> sendTransaction({
    required String mnemonic,
    required String toAddress,
    required int amountSompi,
    required String payloadNote,
    String hrp = 'kaspa',
  }) async {
    // Derive sending address from mnemonic
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/111111'/0'/0/0");
    final ourAddress = _encodeKaspaAddress(child.publicKey, hrp: hrp);

    if (!toAddress.startsWith('$hrp:')) {
      return (txId: '', error: 'Destination must be a valid $hrp: address');
    }

    // Fetch UTXOs
    final utxosUri =
        Uri.parse('https://api.kaspa.org/addresses/$ourAddress/utxos');
    final http.Response utxosResp;
    try {
      utxosResp = await http.get(utxosUri);
    } catch (e) {
      return (txId: '', error: 'UTXO fetch error: $e');
    }

    final List<dynamic> utxoArray;
    try {
      utxoArray = jsonDecode(utxosResp.body) as List<dynamic>;
    } catch (e) {
      return (txId: '', error: 'UTXO parse error: $e');
    }

    const priorityFeeSompi = 1000;
    final required = amountSompi + priorityFeeSompi;

    final selectedUtxos = <Map<String, dynamic>>[];
    var totalInput = 0;
    for (final utxo in utxoArray) {
      final valueStr =
          ((utxo as Map<String, dynamic>)['utxoEntry']['amount'] as String?) ??
          '0';
      final value = int.tryParse(valueStr) ?? 0;
      selectedUtxos.add(utxo);
      totalInput += value;
      if (totalInput >= required) break;
    }

    if (totalInput < required) {
      return (
        txId: '',
        error:
            'Insufficient funds: have $totalInput sompi, need $required sompi',
      );
    }

    final changeSompi = totalInput - amountSompi - priorityFeeSompi;

    // Build inputs
    final inputs = selectedUtxos.map((utxo) {
      final txId =
          (utxo['outpoint']['transactionId'] as String?) ?? '';
      final index = (utxo['outpoint']['index'] as num?)?.toInt() ?? 0;
      return {
        'previousOutpoint': {'transactionId': txId, 'index': index},
        'signatureScript': '',
        'sequence': 0,
        'sigOpCount': 1,
      };
    }).toList();

    // Build outputs
    final toScript = _addressToP2pkScript(toAddress);
    final ourScript = _addressToP2pkScript(ourAddress);
    final outputs = <Map<String, dynamic>>[
      {
        'amount': amountSompi,
        'scriptPublicKey': {'scriptPublicKey': toScript, 'version': 0},
      },
    ];
    if (changeSompi > 0) {
      outputs.add({
        'amount': changeSompi,
        'scriptPublicKey': {'scriptPublicKey': ourScript, 'version': 0},
      });
    }

    // Hex-encode the payload note
    final payloadHex = HEX.encode(utf8.encode(payloadNote));

    final txPayload = {
      'transaction': {
        'version': 0,
        'inputs': inputs,
        'outputs': outputs,
        'lockTime': 0,
        'subnetworkId': '0000000000000000000000000000000000000000',
        'gas': 0,
        'payload': payloadHex,
      },
    };

    // Submit transaction
    final submitUri = Uri.parse('https://api.kaspa.org/transactions');
    final http.Response submitResp;
    try {
      submitResp = await http.post(
        submitUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(txPayload),
      );
    } catch (e) {
      return (txId: '', error: 'Submit error: $e');
    }

    final Map<String, dynamic> result;
    try {
      result = jsonDecode(submitResp.body) as Map<String, dynamic>;
    } catch (e) {
      return (txId: '', error: 'Submit response parse error: $e');
    }

    if (result['transactionId'] is String) {
      return (txId: result['transactionId'] as String, error: '');
    } else if (result['error'] is String) {
      return (txId: '', error: result['error'] as String);
    } else {
      return (txId: '', error: 'Unexpected response: ${jsonEncode(result)}');
    }
  }

  // ---------------------------------------------------------------------------
  // Kaspa cashaddr encoding (custom bech32-like with ':' separator)
  // Ref: kaspa-addresses crate — same polymod generator constants
  // ---------------------------------------------------------------------------

  /// Kaspa cashaddr polymod.
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

  /// Converts a byte array from [fromBits]-bit groups to [toBits]-bit groups.
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

  /// Encodes a 33-byte compressed secp256k1 public key as a Kaspa address
  /// (cashaddr format). [hrp] defaults to 'kaspa' (mainnet); pass
  /// 'kaspatest' for testnet-10.
  static String _encodeKaspaAddress(Uint8List pubkeyBytes, {String hrp = 'kaspa'}) {
    // Version byte 0x00 = PubKey; payload = x-only 32-byte pubkey (skip 02/03 prefix)
    final payload = [0x00, ...pubkeyBytes.sublist(1)];
    final data5 = _convertBits(payload, 8, 5, true);

    // Checksum input: hrp-low-5-bits + separator(0) + data5 + 8 zero placeholders
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
    // Append 8 checksum characters, most-significant bits first
    for (var i = 7; i >= 0; i--) {
      sb.write(_charset[(checksum >> (i * 5)) & 0x1f]);
    }
    return sb.toString();
  }

  /// Decodes a Kaspa address and builds the corresponding P2PK script hex.
  /// Script: OP_DATA_32 (0x20) + 32-byte x-only pubkey + OP_CHECKSIG (0xac)
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

    // Strip 8-char checksum suffix
    if (data5.length < 9) return '';
    final payload5 = data5.sublist(0, data5.length - 8);
    final payload8 = _convertBits(payload5, 5, 8, false);

    // First byte is version (0x00), remaining 32 bytes are the pubkey
    if (payload8.length < 33) return '';
    final pubkey32 = payload8.sublist(1, 33);
    return '20${HEX.encode(pubkey32)}ac';
  }
}
