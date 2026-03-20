import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/data/services/payload_codec.dart';
import 'package:pointycastle/export.dart';

// ---------------------------------------------------------------------------
// Helpers to decode the payload for assertion (mirrors _pack/_encryptGcm)
// ---------------------------------------------------------------------------

// 32-byte key — same as the one hardcoded in KaswayPayloadCodec.
const _key = <int>[
  0xA3, 0x7F, 0x2C, 0xE1, 0x58, 0x94, 0xBB, 0x0D,
  0x3A, 0x61, 0xF7, 0x29, 0x4E, 0xD0, 0x85, 0xC2,
  0x71, 0xB6, 0x39, 0xAF, 0x5D, 0x08, 0xE4, 0x9C,
  0x16, 0xFA, 0x47, 0x2B, 0x8E, 0xD3, 0x60, 0x5A,
];

/// Decrypts an AES-256-GCM blob ([12-byte nonce][ciphertext+tag]).
Uint8List _decryptGcm(Uint8List blob) {
  final nonce = blob.sublist(0, 12);
  final ciphertext = blob.sublist(12);
  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      false,
      AEADParameters(
        KeyParameter(Uint8List.fromList(_key)),
        128,
        nonce,
        Uint8List(0),
      ),
    );
  final out = Uint8List(ciphertext.length - 16);
  var offset = cipher.processBytes(ciphertext, 0, ciphertext.length, out, 0);
  cipher.doFinal(out, offset);
  return out;
}

/// Decode the binary payload back to a structured map.
Map<String, dynamic> _unpack(Uint8List bytes) {
  int pos = 0;

  int readU8() => bytes[pos++];
  int readU16() {
    final v = (bytes[pos] << 8) | bytes[pos + 1];
    pos += 2;
    return v;
  }

  int readU32() {
    final v = (bytes[pos] << 24) |
        (bytes[pos + 1] << 16) |
        (bytes[pos + 2] << 8) |
        bytes[pos + 3];
    pos += 4;
    return v;
  }

  String readStr(int len) {
    final s = utf8.decode(bytes.sublist(pos, pos + len));
    pos += len;
    return s;
  }

  final version = readU8();
  final itemCount = readU8();

  final items = <Map<String, dynamic>>[];
  for (int i = 0; i < itemCount; i++) {
    final nameLen = readU8();
    final name = readStr(nameLen);
    final quantity = readU16();
    final unitPrice = readU32();
    final addCount = readU8();

    final additions = <Map<String, dynamic>>[];
    for (int j = 0; j < addCount; j++) {
      final addNameLen = readU8();
      final addName = readStr(addNameLen);
      final addPrice = readU32();
      additions.add({'name': addName, 'price': addPrice});
    }

    items.add({
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'additions': additions,
    });
  }

  final totalIdr = readU32();

  return {
    'version': version,
    'items': items,
    'totalIdr': totalIdr,
  };
}

/// Full round-trip decode: base64url → decrypt → decompress → unpack.
Map<String, dynamic> _decode(String encoded) {
  final blob = Uint8List.fromList(base64Url.decode(encoded));
  final compressed = _decryptGcm(blob);
  final plain = Uint8List.fromList(zlib.decode(compressed));
  return _unpack(plain);
}

// ---------------------------------------------------------------------------
// Fixture builders
// ---------------------------------------------------------------------------

Product _product({
  String id = 'p1',
  String name = 'Coffee',
  double price = 15000,
}) =>
    Product(id: id, name: name, price: price);

Addition _addition({
  String id = 'a1',
  String name = 'Extra Shot',
  double price = 5000,
}) =>
    Addition(id: id, name: name, price: price);

CartItem _cartItem({
  Product? product,
  double quantity = 1,
  List<Addition> additions = const [],
}) =>
    CartItem(
      product: product ?? _product(),
      quantity: quantity,
      selectedAdditions: additions,
    );

void main() {
  group('KaswayPayloadCodec', () {
    // ── encode returns a non-empty base64url string ──────────────────────────

    test('encode returns non-empty string', () {
      final result = KaswayPayloadCodec.encode([_cartItem()], 15000);
      expect(result, isNotEmpty);
    });

    test('encode output is valid base64url (no padding issues)', () {
      final result = KaswayPayloadCodec.encode([_cartItem()], 15000);
      // Must not throw when decoded
      expect(() => base64Url.decode(result), returnsNormally);
    });

    test('encode produces different ciphertext on each call (random nonce)', () {
      final item = _cartItem();
      final a = KaswayPayloadCodec.encode([item], 15000);
      final b = KaswayPayloadCodec.encode([item], 15000);
      // Same plaintext, different nonce → different ciphertext
      expect(a, isNot(equals(b)));
    });

    // ── empty cart ───────────────────────────────────────────────────────────

    test('empty cart encodes and round-trips correctly', () {
      const totalIdr = 0.0;
      final encoded = KaswayPayloadCodec.encode([], totalIdr);
      final decoded = _decode(encoded);

      expect(decoded['version'], equals(1));
      expect(decoded['items'], isEmpty);
      expect(decoded['totalIdr'], equals(0));
    });

    // ── single item, no additions ────────────────────────────────────────────

    test('single item without additions round-trips correctly', () {
      final product = _product(name: 'Latte', price: 25000);
      final item = _cartItem(product: product, quantity: 2);
      const totalIdr = 50000.0;

      final encoded = KaswayPayloadCodec.encode([item], totalIdr);
      final decoded = _decode(encoded);

      expect(decoded['version'], equals(1));
      expect(decoded['items'], hasLength(1));

      final decodedItem = decoded['items'][0] as Map<String, dynamic>;
      expect(decodedItem['name'], equals('Latte'));
      expect(decodedItem['quantity'], equals(2));
      expect(decodedItem['unitPrice'], equals(25000));
      expect(decodedItem['additions'], isEmpty);

      expect(decoded['totalIdr'], equals(50000));
    });

    // ── single item with additions ───────────────────────────────────────────

    test('single item with additions round-trips correctly', () {
      final product = _product(name: 'Cappuccino', price: 20000);
      final add1 = _addition(name: 'Extra Shot', price: 5000);
      final add2 = _addition(id: 'a2', name: 'Oat Milk', price: 3000);
      final item = _cartItem(
        product: product,
        quantity: 1,
        additions: [add1, add2],
      );
      const totalIdr = 28000.0;

      final encoded = KaswayPayloadCodec.encode([item], totalIdr);
      final decoded = _decode(encoded);

      final decodedItem = decoded['items'][0] as Map<String, dynamic>;
      expect(decodedItem['name'], equals('Cappuccino'));
      expect(decodedItem['unitPrice'], equals(20000));
      expect(decodedItem['additions'], hasLength(2));

      final decodedAdd1 =
          (decodedItem['additions'] as List)[0] as Map<String, dynamic>;
      expect(decodedAdd1['name'], equals('Extra Shot'));
      expect(decodedAdd1['price'], equals(5000));

      final decodedAdd2 =
          (decodedItem['additions'] as List)[1] as Map<String, dynamic>;
      expect(decodedAdd2['name'], equals('Oat Milk'));
      expect(decodedAdd2['price'], equals(3000));

      expect(decoded['totalIdr'], equals(28000));
    });

    // ── multiple items ───────────────────────────────────────────────────────

    test('multiple items round-trip correctly', () {
      final p1 = _product(id: 'p1', name: 'Espresso', price: 12000);
      final p2 = _product(id: 'p2', name: 'Croissant', price: 18000);
      final p3 = _product(id: 'p3', name: 'Juice', price: 22000);

      final add = _addition(name: 'Whip Cream', price: 2000);

      final items = [
        _cartItem(product: p1, quantity: 2),
        _cartItem(product: p2, quantity: 1, additions: [add]),
        _cartItem(product: p3, quantity: 3),
      ];
      const totalIdr = 110000.0;

      final encoded = KaswayPayloadCodec.encode(items, totalIdr);
      final decoded = _decode(encoded);

      expect(decoded['items'], hasLength(3));

      final i0 = decoded['items'][0] as Map<String, dynamic>;
      expect(i0['name'], equals('Espresso'));
      expect(i0['quantity'], equals(2));

      final i1 = decoded['items'][1] as Map<String, dynamic>;
      expect(i1['name'], equals('Croissant'));
      expect(i1['quantity'], equals(1));
      expect(i1['additions'], hasLength(1));

      final i2 = decoded['items'][2] as Map<String, dynamic>;
      expect(i2['name'], equals('Juice'));
      expect(i2['quantity'], equals(3));

      expect(decoded['totalIdr'], equals(110000));
    });

    // ── total matches decoded ────────────────────────────────────────────────

    test('decoded totalIdr matches the value passed to encode', () {
      final item = _cartItem(product: _product(price: 7500), quantity: 4);
      const total = 30000.0;

      final decoded = _decode(KaswayPayloadCodec.encode([item], total));
      expect(decoded['totalIdr'], equals(30000));
    });

    test('total is stored as truncated integer (floor of double)', () {
      // fractional IDR should be truncated via .toInt()
      final item = _cartItem(product: _product(price: 7500));
      const total = 7500.99; // fractional part should be dropped

      final decoded = _decode(KaswayPayloadCodec.encode([item], total));
      expect(decoded['totalIdr'], equals(7500));
    });

    // ── UTF-8 product names ──────────────────────────────────────────────────

    test('UTF-8 product names round-trip correctly', () {
      final product = _product(name: 'Nasi Goreng 炒饭 🍳', price: 30000);
      final item = _cartItem(product: product);

      final decoded = _decode(KaswayPayloadCodec.encode([item], 30000));
      final decodedItem = decoded['items'][0] as Map<String, dynamic>;
      expect(decodedItem['name'], equals('Nasi Goreng 炒饭 🍳'));
    });

    // ── version byte ─────────────────────────────────────────────────────────

    test('encoded payload has version byte 0x01', () {
      final encoded = KaswayPayloadCodec.encode([_cartItem()], 10000);
      final decoded = _decode(encoded);
      expect(decoded['version'], equals(1));
    });

    // ── quantity stored as uint16 ────────────────────────────────────────────

    test('large quantity (uint16 max = 65535) round-trips correctly', () {
      final item = _cartItem(quantity: 65535);
      final decoded = _decode(KaswayPayloadCodec.encode([item], 65535 * 15000));
      final decodedItem = decoded['items'][0] as Map<String, dynamic>;
      expect(decodedItem['quantity'], equals(65535));
    });

    // ── price stored as uint32 ───────────────────────────────────────────────

    test('high unit price (uint32 near max) round-trips correctly', () {
      // 4,000,000 IDR — well within uint32 range (max ~4.29 billion)
      final product = _product(price: 4000000);
      final item = _cartItem(product: product);

      final decoded = _decode(KaswayPayloadCodec.encode([item], 4000000));
      final decodedItem = decoded['items'][0] as Map<String, dynamic>;
      expect(decodedItem['unitPrice'], equals(4000000));
    });

    // ── item with zero price addition ────────────────────────────────────────

    test('addition with zero price round-trips correctly', () {
      final add = _addition(name: 'No Sugar', price: 0);
      final item = _cartItem(additions: [add]);

      final decoded = _decode(KaswayPayloadCodec.encode([item], 15000));
      final decodedItem = decoded['items'][0] as Map<String, dynamic>;
      final decodedAdd =
          (decodedItem['additions'] as List)[0] as Map<String, dynamic>;
      expect(decodedAdd['price'], equals(0));
    });

    // ── blob structure: nonce is first 12 bytes ──────────────────────────────

    test('encrypted blob starts with 12-byte nonce', () {
      final encoded = KaswayPayloadCodec.encode([_cartItem()], 10000);
      final blob = Uint8List.fromList(base64Url.decode(encoded));
      // blob must be at least nonce(12) + 1 byte plaintext + 16 byte tag = 29
      expect(blob.length, greaterThanOrEqualTo(29));
    });
  });
}
