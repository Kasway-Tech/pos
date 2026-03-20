import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:kasway/data/models/cart_item.dart';
import 'package:pointycastle/export.dart';

/// Encodes cart items into a compact, encrypted, zlib-compressed binary blob
/// for embedding in the Kaspa payment QR URI (`p=` parameter).
///
/// The shared key is identical in the companion wallet SDK, allowing it to
/// decode the payload without exposing order details to third parties.
class KaswayPayloadCodec {
  // 32-byte AES-256 key — identical copy ships in the wallet SDK.
  // ignore: constant_identifier_names
  static const _key = <int>[
    0xA3, 0x7F, 0x2C, 0xE1, 0x58, 0x94, 0xBB, 0x0D,
    0x3A, 0x61, 0xF7, 0x29, 0x4E, 0xD0, 0x85, 0xC2,
    0x71, 0xB6, 0x39, 0xAF, 0x5D, 0x08, 0xE4, 0x9C,
    0x16, 0xFA, 0x47, 0x2B, 0x8E, 0xD3, 0x60, 0x5A,
  ];

  /// Encode [items] + [totalIdr] → base64url string for the `p=` QR param.
  static String encode(List<CartItem> items, double totalIdr) {
    final packed = _pack(items, totalIdr);
    final compressed = zlib.encode(packed);
    final encrypted = _encryptGcm(Uint8List.fromList(compressed));
    return base64Url.encode(encrypted);
  }

  // ---------------------------------------------------------------------------
  // Binary packing
  // ---------------------------------------------------------------------------

  /// Binary payload layout:
  /// ```
  /// 0x01          version
  /// uint8         item count
  /// per item:
  ///   uint8       name byte length
  ///   N bytes     name (UTF-8)
  ///   uint16 BE   quantity
  ///   uint32 BE   unit price IDR (whole)
  ///   uint8       addition count
  ///   per addition:
  ///     uint8     name byte length
  ///     N bytes   name (UTF-8)
  ///     uint32 BE addition price IDR (whole)
  /// uint32 BE     total IDR (whole)
  /// ```
  static Uint8List _pack(List<CartItem> items, double totalIdr) {
    final b = BytesBuilder();
    b.addByte(0x01); // version
    b.addByte(items.length);
    for (final item in items) {
      final nameBytes = utf8.encode(item.product.name);
      b.addByte(nameBytes.length);
      b.add(nameBytes);
      _u16(b, item.quantity.toInt());
      _u32(b, item.product.price.toInt());
      b.addByte(item.selectedAdditions.length);
      for (final add in item.selectedAdditions) {
        final addBytes = utf8.encode(add.name);
        b.addByte(addBytes.length);
        b.add(addBytes);
        _u32(b, add.price.toInt());
      }
    }
    _u32(b, totalIdr.toInt());
    return b.toBytes();
  }

  // ---------------------------------------------------------------------------
  // AES-256-GCM encryption
  // ---------------------------------------------------------------------------

  /// Returns: [12-byte nonce][ciphertext + 16-byte GCM tag]
  static Uint8List _encryptGcm(Uint8List plaintext) {
    final nonce = _randomBytes(12);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(Uint8List.fromList(_key)),
          128, // tag length in bits
          nonce,
          Uint8List(0), // no additional data
        ),
      );
    final out = Uint8List(plaintext.length + 16); // +16 for GCM tag
    var offset = cipher.processBytes(plaintext, 0, plaintext.length, out, 0);
    cipher.doFinal(out, offset);
    return Uint8List.fromList([...nonce, ...out]);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Uint8List _randomBytes(int n) {
    final r = Random.secure();
    return Uint8List.fromList(List.generate(n, (_) => r.nextInt(256)));
  }

  static void _u16(BytesBuilder b, int v) =>
      b.add([(v >> 8) & 0xFF, v & 0xFF]);

  static void _u32(BytesBuilder b, int v) => b.add([
        (v >> 24) & 0xFF,
        (v >> 16) & 0xFF,
        (v >> 8) & 0xFF,
        v & 0xFF,
      ]);
}
