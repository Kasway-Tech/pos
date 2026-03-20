import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:presentation_displays/secondary_display.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'app/simple_bloc_observer.dart';

// ---------------------------------------------------------------------------
// Secondary display entry point (Android / iOS only)
// ---------------------------------------------------------------------------

final ValueNotifier<Map<dynamic, dynamic>?> _secondaryDisplayData =
    ValueNotifier(null);

@pragma('vm:entry-point')
void secondaryDisplayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ValueListenableBuilder<Map<dynamic, dynamic>?>(
      valueListenable: _secondaryDisplayData,
      builder: (context, data, child) => SecondaryDisplay(
        callback: (payload) {
          _secondaryDisplayData.value = payload as Map<dynamic, dynamic>?;
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(useMaterial3: true),
          home: _SecondaryPaymentScreen(data: data),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Secondary display UI
// ---------------------------------------------------------------------------

/// Renders the payment QR code and order summary on the external monitor.
/// All display data arrives as a pre-serialised [Map] from the primary engine.
class _SecondaryPaymentScreen extends StatelessWidget {
  const _SecondaryPaymentScreen({required this.data});

  final Map<dynamic, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    if (data == null) return const _WaitingScreen();

    final qr = data!['qr'] as String?;
    final kas = data!['kas'] as String?;
    final idr = data!['idr'] as String?;
    final rawItems = data!['items'] as List<dynamic>?;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store_outlined, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Kasway POS',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (kas != null)
                Text(
                  kas,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

              if (idr != null && idr.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  idr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),

              if (qr != null && qr.isNotEmpty)
                Center(
                  child: QrImageView(
                    data: qr,
                    version: QrVersions.auto,
                    size: 300,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),

              const SizedBox(height: 24),

              if (rawItems != null && rawItems.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Order',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...rawItems.map((raw) => _OrderItemRow(
                      item: raw as Map<dynamic, dynamic>,
                    )),
              ],

              const SizedBox(height: 32),

              Text(
                'Scan QR code to pay',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final Map<dynamic, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? '';
    final qty = item['qty'] as int? ?? 1;
    final additions =
        (item['additions'] as List<dynamic>?)?.cast<String>() ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$qty×',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyLarge),
                if (additions.isNotEmpty)
                  Text(
                    additions.join(', '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Idle screen shown before a payment is initiated.
class _WaitingScreen extends StatelessWidget {
  const _WaitingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 20),
            Text(
              'Kasway POS',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for payment…',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Primary entry point
// ---------------------------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS) {
    await windowManager.ensureInitialized();

    await WindowManipulator.initialize(enableWindowDelegate: true);

    WindowManipulator.makeTitlebarTransparent();
    WindowManipulator.hideTitle();
    WindowManipulator.enableFullSizeContentView();

    // Delay showing the window until Flutter has painted its first frame to
    // avoid a brief black background before the splash screen renders.
    windowManager.waitUntilReadyToShow(null, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Bloc.observer = const SimpleBlocObserver();

  final prefs = await SharedPreferences.getInstance();

  runApp(App(prefs: prefs));
}
