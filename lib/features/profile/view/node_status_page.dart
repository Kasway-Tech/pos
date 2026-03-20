import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';

class NodeStatusPage extends StatefulWidget {
  const NodeStatusPage({super.key});

  @override
  State<NodeStatusPage> createState() => _NodeStatusPageState();
}

class _NodeStatusPageState extends State<NodeStatusPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  bool _connected = false;
  String _daaScore = '—';
  String _error = 'Connecting…';
  int _updateCount = 0;
  String _lastUpdated = '';
  late String _currentUrl;
  late String _networkLabel;

  WebSocket? _socket;
  bool _disposed = false;
  int _reqId = 1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final networkState = context.read<NetworkCubit>().state;
    _currentUrl = networkState.activeUrl;
    _networkLabel = networkState.networkLabel;
    _connect();
  }

  Future<void> _connect() async {
    while (!_disposed) {
      try {
        final ws = await WebSocket.connect(_currentUrl);
        if (_disposed) {
          await ws.close();
          return;
        }
        _socket = ws;
        if (mounted) setState(() { _connected = true; _error = ''; });

        // Poll DAA score every second while the socket is open.
        void poll() {
          if (!_disposed && ws.readyState == WebSocket.open) {
            ws.add(jsonEncode({
              'id': _reqId++,
              'method': 'getBlockDagInfo',
              'params': {},
            }));
          }
        }
        poll();
        final timer = Stream.periodic(const Duration(seconds: 1))
            .listen((_) => poll());

        await for (final raw in ws) {
          if (_disposed) break;
          if (raw is String) _handleFrame(raw);
        }
        await timer.cancel();

        if (_disposed) return;
        if (mounted) setState(() { _connected = false; _error = 'Connection closed'; });
      } on WebSocketException catch (e) {
        if (_disposed) return;
        if (mounted) setState(() { _connected = false; _error = e.message; });
      } catch (e) {
        if (_disposed) return;
        if (mounted) setState(() { _connected = false; _error = e.toString(); });
      }

      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> _reconnect(String newUrl, String newLabel) async {
    _disposed = true;
    await _socket?.close();
    // Give the event loop a tick to process socket closure before resetting.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    setState(() {
      _disposed = false;
      _connected = false;
      _error = 'Connecting…';
      _daaScore = '—';
      _currentUrl = newUrl;
      _networkLabel = newLabel;
      _updateCount = 0;
      _lastUpdated = '';
    });
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
          '${now.second.toString().padLeft(2, '0')}.'
          '${now.millisecond.toString().padLeft(3, '0')}';
      if (mounted) {
        setState(() {
          _connected = true;
          _error = '';
          _daaScore = score.toString();
          _updateCount++;
          _lastUpdated = timeStr;
        });
        _pulseController.forward(from: 0);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    _socket?.close();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<NetworkCubit, NetworkState>(
      listenWhen: (previous, current) =>
          previous.activeUrl != current.activeUrl,
      listener: (context, state) {
        _reconnect(state.activeUrl, state.networkLabel);
      },
      child: Scaffold(
        appBar: BlurAppBar(title: const Text('Node Status'), centerTitle: true),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Network label badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _networkLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _StatusChip(
                    connected: _connected,
                    nodeUrl: _currentUrl,
                    error: _error,
                  ),
                  const SizedBox(height: 48),
                  _PulseDisplay(
                    controller: _pulseController,
                    child: Text(
                      _daaScore,
                      style: textTheme.displaySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Virtual DAA Score',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_updateCount > 0)
                    Text(
                      'Update #$_updateCount — $_lastUpdated',
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.connected,
    required this.nodeUrl,
    required this.error,
  });

  final bool connected;
  final String nodeUrl;
  final String error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final color = connected ? Colors.green : colorScheme.error;
    final label = connected ? 'Connected' : 'Disconnected';

    String displayUrl = nodeUrl;
    if (displayUrl.length > 40) {
      displayUrl = '${displayUrl.substring(0, 37)}…';
    }

    return Column(
      children: [
        Chip(
          avatar: Icon(Icons.circle, size: 12, color: color),
          label: Text(label, style: TextStyle(color: color)),
          backgroundColor: color.withAlpha(25),
          side: BorderSide(color: color.withAlpha(80)),
        ),
        const SizedBox(height: 6),
        Text(
          displayUrl,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
        if (!connected && error.isNotEmpty && error != 'Connecting…') ...[
          const SizedBox(height: 6),
          Text(
            error,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pulse ring animation
// ---------------------------------------------------------------------------

class _PulseDisplay extends StatelessWidget {
  const _PulseDisplay({required this.controller, required this.child});

  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, innerChild) {
        final opacity = (1.0 - controller.value).clamp(0.0, 1.0);
        final scale = 1.0 + controller.value * 0.2;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (controller.value > 0)
              Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withAlpha(100),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            innerChild!,
          ],
        );
      },
      child: child,
    );
  }
}
