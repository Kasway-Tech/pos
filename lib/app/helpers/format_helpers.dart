// Shared formatting utilities used across multiple features.

/// Truncates a long address (or any hash string) for display.
///
/// Shows the first [visibleStart] characters, an ellipsis, and the last
/// [visibleEnd] characters. Returns [addr] unchanged when it is short enough
/// that truncation would not save space.
String truncateAddress(
  String addr, {
  int visibleStart = 14,
  int visibleEnd = 6,
}) {
  final threshold = visibleStart + visibleEnd;
  if (addr.length <= threshold) return addr;
  return '${addr.substring(0, visibleStart)}…'
      '${addr.substring(addr.length - visibleEnd)}';
}

/// Formats a KAS amount with up to 8 decimal places, stripping trailing zeros.
///
/// Always retains at least two decimal places so amounts like `5.` become
/// `5.00`.
String formatKas(double kas) {
  final s = kas.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
  return s.endsWith('.') ? '${s}00' : s;
}
