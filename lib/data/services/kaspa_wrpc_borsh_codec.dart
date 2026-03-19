import 'dart:convert';
import 'dart:typed_data';

/// Encode/decode Kaspa wRPC Borsh frames.
/// Wire format based on workflow-rpc crate + kaspa-rpc-core RpcApiOps.
class KaspaWrpcBorshCodec {
  // ── Op codes (RpcApiOps discriminants, u8) ──────────────────────────────
  static const int opNotifyUtxosChanged = 12;        // subscribe/unsubscribe
  static const int opUtxosChangedNotification = 64;  // server → client

  // ── ServerMessageKind ───────────────────────────────────────────────────
  static const int kindSuccess = 0;
  static const int kindError = 1;
  static const int kindNotification = 0xff;

  // ── Request encoding ────────────────────────────────────────────────────

  /// Build a binary wRPC Borsh request frame.
  static Uint8List buildRequest(int id, int op, Uint8List payload) {
    final builder = BytesBuilder(copy: false);
    // Option<u64> Some(id)
    builder.addByte(0x01);
    final idBuf = ByteData(8)..setUint64(0, id, Endian.little);
    builder.add(idBuf.buffer.asUint8List());
    // u8 op
    builder.addByte(op);
    builder.add(payload);
    return builder.toBytes();
  }

  /// Encode a NotifyUtxosChanged (subscribe) payload.
  static Uint8List encodeSubscribeUtxosChanged(List<String> addresses) {
    final builder = BytesBuilder(copy: false);
    // TODO: if server rejects, try prepending [0x01, 0x00] (u16 version = 1)
    _writeU32LE(builder, addresses.length);
    for (final addr in addresses) {
      final bytes = utf8.encode(addr);
      _writeU32LE(builder, bytes.length);
      builder.add(bytes);
    }
    // Command::Start = 0
    builder.addByte(0x00);
    return builder.toBytes();
  }

  // ── Response / notification decoding ────────────────────────────────────

  /// Decode the frame header. Returns null if bytes are too short.
  /// [payloadOffset] is the index where the payload starts.
  static ({int? id, int kind, int? op, int payloadOffset})? decodeFrameHeader(
      Uint8List bytes) {
    int offset = 0;
    if (bytes.isEmpty) return null;

    // Option<u64> id
    int? id;
    final idTag = bytes[offset++];
    if (idTag == 0x01) {
      if (bytes.length < offset + 8) return null;
      id = ByteData.sublistView(bytes, offset, offset + 8)
          .getUint64(0, Endian.little);
      offset += 8;
    }

    if (bytes.length <= offset) return null;
    final kind = bytes[offset++];

    // Option<u8> op
    int? op;
    if (bytes.length > offset) {
      final opTag = bytes[offset++];
      if (opTag == 0x01 && bytes.length > offset) {
        op = bytes[offset++];
      }
    }

    return (id: id, kind: kind, op: op, payloadOffset: offset);
  }

  /// Parse UtxosChangedNotification payload.
  /// Returns a list of added UTXOs: (address, amountSompi).
  /// Returns [] on parse failure (don't crash).
  static List<({String? address, int amountSompi})> decodeUtxosChangedAdded(
      Uint8List payload) {
    try {
      // TODO: if result is always empty, try skipping 1 or 2 version bytes at start
      int offset = 0;
      final result = <({String? address, int amountSompi})>[];

      if (payload.length < 4) return result;
      final addedCount = _readU32LE(payload, offset);
      offset += 4;

      for (int i = 0; i < addedCount; i++) {
        // Option<address>
        String? address;
        if (offset >= payload.length) break;
        final addrTag = payload[offset++];
        if (addrTag == 0x01) {
          final addrLen = _readU32LE(payload, offset);
          offset += 4;
          address = utf8.decode(payload.sublist(offset, offset + addrLen));
          offset += addrLen;
        }

        // RpcTransactionOutpoint: 32-byte txid + u32 index
        // TODO: if decoding fails, try skipping a u8 version byte here
        offset += 32 + 4;

        // RpcUtxoEntry
        // TODO: if decoding fails, try skipping a u8 version byte here
        if (offset + 8 > payload.length) break;
        final amountSompi = ByteData.sublistView(payload, offset, offset + 8)
            .getUint64(0, Endian.little);
        offset += 8;

        // ScriptPublicKey: u16 version + u32 len + script bytes
        if (offset + 6 > payload.length) break;
        offset += 2; // script version
        final scriptLen = _readU32LE(payload, offset);
        offset += 4;
        offset += scriptLen;

        // u64 block_daa_score + u8 is_coinbase
        offset += 8 + 1;

        result.add((address: address, amountSompi: amountSompi));
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static void _writeU32LE(BytesBuilder b, int value) {
    final buf = ByteData(4)..setUint32(0, value, Endian.little);
    b.add(buf.buffer.asUint8List());
  }

  static int _readU32LE(Uint8List bytes, int offset) =>
      ByteData.sublistView(bytes, offset, offset + 4)
          .getUint32(0, Endian.little);
}
