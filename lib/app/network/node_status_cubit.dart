import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'node_status_state.dart';

class NodeStatusCubit extends Cubit<NodeStatusState> {
  NodeStatusCubit({required NetworkCubit networkCubit})
      : super(const NodeStatusState()) {
    _currentUrl = networkCubit.state.activeUrl;
    _connect();
    _networkSub = networkCubit.stream.listen((networkState) {
      if (networkState.activeUrl != _currentUrl) {
        _reconnect(networkState.activeUrl);
      }
    });
  }

  late String _currentUrl;
  StreamSubscription<NetworkState>? _networkSub;
  WebSocket? _socket;
  bool _disposed = false;
  int _reqId = 1;

  Future<void> _connect() async {
    while (!_disposed) {
      try {
        final ws = await WebSocket.connect(_currentUrl);
        if (_disposed) {
          await ws.close();
          return;
        }
        _socket = ws;
        emit(state.copyWith(connected: true, error: ''));

        void poll() {
          if (_disposed || ws.readyState != WebSocket.open) return;
          try {
            ws.add(jsonEncode(
                {'id': _reqId++, 'method': 'getBlockDagInfo', 'params': {}}));
          } catch (_) {}
        }

        poll();
        final timer =
            Stream.periodic(const Duration(seconds: 1)).listen((_) => poll());

        await for (final raw in ws) {
          if (_disposed) break;
          if (raw is String) _handleFrame(raw);
        }
        await timer.cancel();

        if (_disposed) return;
        emit(state.copyWith(connected: false, error: 'Connection closed'));
      } on WebSocketException catch (e) {
        if (_disposed) return;
        emit(state.copyWith(connected: false, error: e.message));
      } catch (e) {
        if (_disposed) return;
        emit(state.copyWith(connected: false, error: e.toString()));
      }

      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> _reconnect(String newUrl) async {
    _disposed = true;
    await _socket?.close();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _currentUrl = newUrl;
    _disposed = false;
    emit(const NodeStatusState());
    _connect();
  }

  void _handleFrame(String text) {
    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      final params = json['params'] as Map<String, dynamic>?;
      final score = params?['virtualDaaScore'];
      if (score == null) return;
      final now = DateTime.now();
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';
      emit(state.copyWith(
        connected: true,
        error: '',
        daaScore: score.toString(),
        lastUpdated: timeStr,
      ));
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    _disposed = true;
    _networkSub?.cancel();
    await _socket?.close();
    return super.close();
  }
}
