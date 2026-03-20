// Sentinel object used by copyWith to distinguish "not provided" from null.
const _sentinel = Object();

enum DisplayStatus { idle, scanning, connected, error }

class DisplayState {
  const DisplayState({
    this.enabled = false,
    this.status = DisplayStatus.idle,
    this.availableDisplays = const [],
    this.connectedDisplayId,
    this.connectedDisplayName,
    this.lastKnownDisplayId,
    this.errorMessage,
  });

  final bool enabled;
  final DisplayStatus status;

  /// Displays found during the last scan (excludes primary display id 0).
  final List<({int id, String name})> availableDisplays;

  final int? connectedDisplayId;
  final String? connectedDisplayName;

  /// Last successfully connected display id – persisted for auto-reconnect.
  final int? lastKnownDisplayId;

  final String? errorMessage;

  bool get isConnected =>
      status == DisplayStatus.connected && connectedDisplayId != null;

  DisplayState copyWith({
    bool? enabled,
    DisplayStatus? status,
    List<({int id, String name})>? availableDisplays,
    Object? connectedDisplayId = _sentinel,
    Object? connectedDisplayName = _sentinel,
    Object? lastKnownDisplayId = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return DisplayState(
      enabled: enabled ?? this.enabled,
      status: status ?? this.status,
      availableDisplays: availableDisplays ?? this.availableDisplays,
      connectedDisplayId: connectedDisplayId == _sentinel
          ? this.connectedDisplayId
          : connectedDisplayId as int?,
      connectedDisplayName: connectedDisplayName == _sentinel
          ? this.connectedDisplayName
          : connectedDisplayName as String?,
      lastKnownDisplayId: lastKnownDisplayId == _sentinel
          ? this.lastKnownDisplayId
          : lastKnownDisplayId as int?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
