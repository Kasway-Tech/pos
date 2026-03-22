import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'network_cubit.dart';
import 'network_state.dart';
import 'node_status_state.dart';

class NodeStatusCubit extends Cubit<NodeStatusState> {
  NodeStatusCubit({required NetworkCubit networkCubit})
      : _networkCubit = networkCubit,
        super(const NodeStatusState()) {
    _currentUrl = networkCubit.state.activeUrl;
    _connect();
    _networkSub = networkCubit.stream.listen((networkState) {
      if (networkState.activeUrl != _currentUrl) {
        _reconnect(networkState.activeUrl);
      }
    });
  }

  final NetworkCubit _networkCubit;

  late String _currentUrl;
  StreamSubscription<NetworkState>? _networkSub;
  WebSocket? _socket;

  // Incremented on every reconnect so stale _connect() loops self-terminate.
  int _generation = 0;

  int _reqId = 1;

  // How many consecutive connection failures before asking the resolver to
  // find a fresh node URL.
  int _consecutiveFailures = 0;
  static const _reResolveThreshold = 3;

  Future<void> _connect() async {
    final myGeneration = _generation;
    await runZonedGuarded(() async {
      while (!isClosed && _generation == myGeneration) {
        try {
          final ws = await WebSocket.connect(_currentUrl);

          if (isClosed || _generation != myGeneration) {
            ws.close().ignore();
            return;
          }

          _socket = ws;
          _consecutiveFailures = 0;
          emit(state.copyWith(connected: true, error: ''));

          void poll() {
            if (isClosed || _generation != myGeneration) return;
            if (ws.readyState != WebSocket.open) return;
            try {
              ws.add(jsonEncode({
                'id': _reqId++,
                'method': 'getBlockDagInfo',
                'params': {},
              }));
            } catch (_) {}
          }

          poll();
          final timer =
              Stream.periodic(const Duration(seconds: 1)).listen((_) => poll());

          await for (final raw in ws) {
            if (_generation != myGeneration) break;
            if (raw is String) _handleFrame(raw, myGeneration);
          }
          await timer.cancel();

          if (isClosed || _generation != myGeneration) return;
          _onFailure(myGeneration, 'Connection closed');
        } on WebSocketException catch (e) {
          if (isClosed || _generation != myGeneration) return;
          _onFailure(myGeneration, e.message);
        } catch (e) {
          if (isClosed || _generation != myGeneration) return;
          _onFailure(myGeneration, e.toString());
        }

        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }, (e, _) {
      // SocketException thrown by dart:io internals after socket close;
      // not catchable by regular try/catch — silently swallow.
      if (e is! SocketException) debugPrint('[NodeStatus] zone: $e');
    });
  }

  void _onFailure(int myGeneration, String errorMessage) {
    if (isClosed || _generation != myGeneration) return;
    emit(state.copyWith(connected: false, error: errorMessage));
    _consecutiveFailures++;
    if (_consecutiveFailures >= _reResolveThreshold) {
      _consecutiveFailures = 0;
      unawaited(_networkCubit.triggerResolve());
    }
  }

  Future<void> _reconnect(String newUrl) async {
    _generation++; // invalidates all in-flight _connect() loops
    _currentUrl = newUrl;
    _consecutiveFailures = 0;
    await _socket?.close();
    _socket = null;
    emit(const NodeStatusState());
    _connect();
  }

  void _handleFrame(String text, int generation) {
    if (_generation != generation) return;
    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      final params = json['params'] as Map<String, dynamic>?;
      final score = params?['virtualDaaScore'];
      if (score == null) return;
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';
      emit(state.copyWith(
        connected: true,
        error: '',
        daaScore: (score as num).toInt().toString(),
        lastUpdated: timeStr,
      ));
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    _generation++;
    _networkSub?.cancel();
    await _socket?.close();
    return super.close();
  }
}
