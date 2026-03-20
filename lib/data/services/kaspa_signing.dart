library;

/// Pure-Dart Kaspa transaction signing.
///
/// Implements:
///   - Kaspa sighash (BLAKE2b-256 keyed with "TransactionSigningHash")
///   - BIP340 Schnorr signing on secp256k1
///
/// References:
///   - rusty-kaspa/consensus/core/src/hashing/sighash.rs
///   - rusty-kaspa/consensus/core/src/sign.rs
///   - BIP-340 (Schnorr signatures for secp256k1)

import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/digests/blake2b.dart';

// ─────────────────────────────────────────────────────────────────────────────
// secp256k1 parameters
// ─────────────────────────────────────────────────────────────────────────────

final _p = BigInt.parse(
  'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
  radix: 16,
);
final _n = BigInt.parse(
  'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
  radix: 16,
);
final _gx = BigInt.parse(
  '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
  radix: 16,
);
final _gy = BigInt.parse(
  '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',
  radix: 16,
);

// ─────────────────────────────────────────────────────────────────────────────
// secp256k1 point arithmetic (affine coordinates)
// ─────────────────────────────────────────────────────────────────────────────

class _Pt {
  static final _Pt inf = _Pt(BigInt.zero, BigInt.zero);
  static final _Pt G = _Pt(_gx, _gy);

  final BigInt x, y;
  _Pt(this.x, this.y);

  bool get isInfinity => x == BigInt.zero && y == BigInt.zero;

  _Pt add(_Pt q) {
    if (isInfinity) return q;
    if (q.isInfinity) return this;

    final BigInt lam;
    if (x == q.x) {
      if (y != q.y) return _Pt.inf; // negatives → infinity
      // Point doubling: λ = 3x² / 2y  (mod p)
      lam = BigInt.from(3) * x % _p * x % _p * _modinv(BigInt.two * y, _p) % _p;
    } else {
      // General addition: λ = (y₂ − y₁) / (x₂ − x₁)  (mod p)
      lam = _posmod((q.y - y) * _modinv(q.x - x, _p));
    }

    final rx = _posmod(lam * lam - x - q.x);
    final ry = _posmod(lam * (x - rx) - y);
    return _Pt(rx, ry);
  }

  _Pt mul(BigInt k) {
    k = k % _n;
    var result = _Pt.inf;
    var cur = this;
    while (k > BigInt.zero) {
      if (k.isOdd) result = result.add(cur);
      cur = cur.add(cur);
      k >>= 1;
    }
    return result;
  }
}

BigInt _posmod(BigInt x) {
  final r = x % _p;
  return r.isNegative ? r + _p : r;
}

BigInt _modinv(BigInt a, BigInt m) {
  a = a % m;
  if (a.isNegative) a += m;
  return a.modPow(m - BigInt.two, m);
}

// ─────────────────────────────────────────────────────────────────────────────
// Byte-encoding helpers (little-endian, matching Kaspa's Rust types)
// ─────────────────────────────────────────────────────────────────────────────

Uint8List _u8(int v) => Uint8List.fromList([v & 0xff]);

Uint8List _u16le(int v) {
  final b = ByteData(2)..setUint16(0, v & 0xffff, Endian.little);
  return b.buffer.asUint8List();
}

Uint8List _u32le(int v) {
  final b = ByteData(4)..setUint32(0, v & 0xffffffff, Endian.little);
  return b.buffer.asUint8List();
}

/// 8-byte little-endian u64.  Dart native int is 63-bit signed;
/// all sompi values fit (max supply ≈ 2.87 × 10¹⁸ < 2⁶³).
Uint8List _u64le(int v) {
  final b = ByteData(8)
    ..setUint32(0, v & 0xffffffff, Endian.little)
    ..setUint32(4, v >>> 32, Endian.little);
  return b.buffer.asUint8List();
}

/// Kaspa `write_var_bytes`: 8-byte LE length prefix + raw bytes.
Uint8List _varBytes(Uint8List data) =>
    Uint8List.fromList([..._u64le(data.length), ...data]);

Uint8List _fromHex(String hex) => Uint8List.fromList(HEX.decode(hex));

BigInt _bigIntFromBytes(Uint8List b) => BigInt.parse(HEX.encode(b), radix: 16);

Uint8List _bigIntToBytes32(BigInt n) {
  final hex = n.toRadixString(16).padLeft(64, '0');
  return Uint8List.fromList(
    List.generate(32, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BLAKE2b-256 keyed with "TransactionSigningHash"
// (rusty-kaspa uses blake2b_simd::Params::new().hash_length(32).key(domain))
// ─────────────────────────────────────────────────────────────────────────────

const _sigHashKey = 'TransactionSigningHash';

/// Wraps pointycastle Blake2bDigest for incremental hashing.
class _Blake2bHasher {
  final Blake2bDigest _digest;

  _Blake2bHasher()
      : _digest = Blake2bDigest(
          digestSize: 32,
          key: Uint8List.fromList(_sigHashKey.codeUnits),
        );

  void update(Uint8List data) => _digest.update(data, 0, data.length);

  Uint8List digest() {
    final out = Uint8List(32);
    _digest.doFinal(out, 0);
    return out;
  }
}

_Blake2bHasher _newHasher() => _Blake2bHasher();

// ─────────────────────────────────────────────────────────────────────────────
// BIP340 Schnorr signing
// ─────────────────────────────────────────────────────────────────────────────

/// BIP340 tagged SHA-256: SHA256(SHA256(tag) ‖ SHA256(tag) ‖ data)
Uint8List _tagged(String tag, List<int> data) {
  final th = sha256.convert(tag.codeUnits).bytes;
  return Uint8List.fromList(sha256.convert([...th, ...th, ...data]).bytes);
}

/// Signs [msg32] (32 bytes) with secp256k1 private key [privKey32] (32 bytes).
/// Returns a 64-byte BIP340 Schnorr signature.
Uint8List kaspaSchnorrSign(Uint8List privKey32, Uint8List msg32) {
  assert(privKey32.length == 32 && msg32.length == 32);

  var sec = _bigIntFromBytes(privKey32);
  final P = _Pt.G.mul(sec);

  // BIP340: negate seckey when P.y is odd so the public key has even Y.
  if (P.y.isOdd) sec = _n - sec;

  final secBytes = _bigIntToBytes32(sec);
  final px = _bigIntToBytes32(P.x);

  // Deterministic nonce — all-zero aux randomness (deterministic, safe for signing).
  final t = Uint8List(32);
  final auxHash = _tagged('BIP0340/aux', Uint8List(32));
  for (var i = 0; i < 32; i++) {
    t[i] = secBytes[i] ^ auxHash[i];
  }

  final nonceBytes = _tagged('BIP0340/nonce', [...t, ...px, ...msg32]);
  var k = _bigIntFromBytes(nonceBytes) % _n;
  if (k == BigInt.zero) throw StateError('BIP340 nonce is zero — retry');

  final R = _Pt.G.mul(k);
  if (R.y.isOdd) k = _n - k;

  final rx = _bigIntToBytes32(R.x);
  final e =
      _bigIntFromBytes(_tagged('BIP0340/challenge', [...rx, ...px, ...msg32])) % _n;
  final s = (k + e * sec) % _n;

  return Uint8List.fromList([...rx, ..._bigIntToBytes32(s)]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Kaspa sighash (SIG_HASH_ALL = 0x01)
// Source: rusty-kaspa/consensus/core/src/hashing/sighash.rs
// ─────────────────────────────────────────────────────────────────────────────

/// Info about a UTXO being spent (from getUtxosByAddresses).
class KaspaUtxo {
  final int amount;         // sompi
  final int scriptVersion;  // u16 from compact SPK (first 2 bytes LE)
  final Uint8List script;   // bytes after version in compact SPK

  const KaspaUtxo({
    required this.amount,
    required this.scriptVersion,
    required this.script,
  });
}

/// Info about an output being created.
class KaspaOutput {
  final int value;           // sompi
  final int scriptVersion;   // 0 for P2PK
  final Uint8List script;    // 34-byte P2PK script

  const KaspaOutput({
    required this.value,
    required this.scriptVersion,
    required this.script,
  });
}

/// Computes the Kaspa Schnorr sighash for input at [inputIndex].
///
/// Assumes:
///   - SIG_HASH_ALL (0x01)
///   - sequence = 0 for all inputs
///   - lockTime = 0, gas = 0
///   - native subnetwork (20 zero bytes)
///   - empty payload (payload hash = 32 zero bytes)
///   - sigOpCount = 1 for all inputs (P2PK)
Uint8List calcKaspaSigHash({
  required int txVersion,
  required List<String> txIds,   // hex txid per input
  required List<int> indices,    // outpoint index per input
  required List<KaspaUtxo> utxos,
  required List<KaspaOutput> outputs,
  required int inputIndex,
}) {
  final n = txIds.length;

  // --- previousOutputsHash ---
  final hPrev = _newHasher();
  for (var i = 0; i < n; i++) {
    hPrev.update(_fromHex(txIds[i]));
    hPrev.update(_u32le(indices[i]));
  }
  final prevOutsHash = hPrev.digest();

  // --- sequencesHash ---
  final hSeq = _newHasher();
  for (var i = 0; i < n; i++) {
    hSeq.update(_u64le(0)); // sequence = 0
  }
  final seqHash = hSeq.digest();

  // --- sigOpCountsHash --- (1 for every P2PK input)
  final hSigOp = _newHasher();
  for (var i = 0; i < n; i++) {
    hSigOp.update(_u8(1));
  }
  final sigOpHash = hSigOp.digest();

  // --- outputsHash ---
  final hOut = _newHasher();
  for (final out in outputs) {
    hOut.update(_u64le(out.value));
    hOut.update(_u16le(out.scriptVersion));
    hOut.update(_varBytes(out.script));
  }
  final outsHash = hOut.digest();

  // payloadHash = 32 zero bytes (empty payload on native subnetwork)
  final payloadHash = Uint8List(32);

  // --- Final sighash ---
  final h = _newHasher();
  h.update(_u16le(txVersion));
  h.update(prevOutsHash);
  h.update(seqHash);
  h.update(sigOpHash);
  // Per-input UTXO commitment
  h.update(_fromHex(txIds[inputIndex]));
  h.update(_u32le(indices[inputIndex]));
  h.update(_u16le(utxos[inputIndex].scriptVersion));
  h.update(_varBytes(utxos[inputIndex].script));
  h.update(_u64le(utxos[inputIndex].amount));
  h.update(_u64le(0)); // sequence = 0
  h.update(_u8(1));    // sigOpCount = 1
  // Transaction-level fields
  h.update(outsHash);
  h.update(_u64le(0));       // lockTime = 0
  h.update(Uint8List(20));   // SUBNETWORK_ID_NATIVE = 20 zero bytes
  h.update(_u64le(0));       // gas = 0
  h.update(payloadHash);
  h.update(_u8(0x01));       // SIG_HASH_ALL
  return h.digest();
}

// ─────────────────────────────────────────────────────────────────────────────
// Signature script + SPK helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Builds the P2PK signatureScript: OP_DATA_65 (0x41) + 64-byte sig + SIG_HASH_ALL (0x01).
Uint8List buildP2pkSigScript(Uint8List sig64) {
  assert(sig64.length == 64);
  return Uint8List.fromList([0x41, ...sig64, 0x01]);
}

/// Parses a compact Kaspa scriptPublicKey hex string ("VVVV{script_hex}")
/// into its version (u16 LE from first 2 bytes) and raw script bytes.
({int version, Uint8List script}) parseCompactSpk(String compactHex) {
  final bytes = _fromHex(compactHex);
  if (bytes.length < 2) return (version: 0, script: Uint8List(0));
  final version = bytes[0] | (bytes[1] << 8); // little-endian u16
  return (version: version, script: Uint8List.fromList(bytes.sublist(2)));
}
