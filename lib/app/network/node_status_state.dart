import 'package:equatable/equatable.dart';

class NodeStatusState extends Equatable {
  const NodeStatusState({
    this.connected = false,
    this.daaScore = '—',
    this.error = 'Connecting…',
    this.lastUpdated = '',
  });

  final bool connected;
  final String daaScore;
  final String error;
  final String lastUpdated;

  NodeStatusState copyWith({
    bool? connected,
    String? daaScore,
    String? error,
    String? lastUpdated,
  }) => NodeStatusState(
    connected: connected ?? this.connected,
    daaScore: daaScore ?? this.daaScore,
    error: error ?? this.error,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );

  @override
  List<Object?> get props => [connected, daaScore, error, lastUpdated];
}
