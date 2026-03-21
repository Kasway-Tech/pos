import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/display/display_cubit.dart';
import 'package:kasway/app/display/display_state.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';

class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({super.key});

  bool get _isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlurAppBar(
        title: Text(context.l10n.displayTitle),
        centerTitle: true,
      ),
      body: BlocBuilder<DisplayCubit, DisplayState>(
        builder: (context, state) {
          final cubit = context.read<DisplayCubit>();
          final l10n = context.l10n;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                children: [
                  _Section(
                    child: SwitchListTile(
                      value: state.enabled,
                      onChanged: _isSupported
                          ? (v) => cubit.setEnabled(v)
                          : null,
                      title: Text(l10n.displayTitle),
                      subtitle: Text(
                        _isSupported
                            ? l10n.displaySubtitle
                            : l10n.displayNotSupported,
                      ),
                      secondary: const Icon(Icons.tv_outlined),
                    ),
                  ),

                  if (state.enabled && _isSupported) ...[
                    const SizedBox(height: 16),
                    _Section(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                            child: Row(
                              children: [
                                _SectionTitle(l10n.displayAvailableDisplays),
                                const Spacer(),
                                FilledButton.tonal(
                                  onPressed:
                                      state.status == DisplayStatus.scanning
                                      ? null
                                      : () => cubit.scanDisplays(),
                                  child: Text(l10n.displayScan),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),

                          if (state.status == DisplayStatus.scanning)
                            const LinearProgressIndicator(),

                          if (state.availableDisplays.isEmpty &&
                              state.status != DisplayStatus.scanning)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: Text(
                                l10n.displayNoDisplays,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                              ),
                            )
                          else
                            ...state.availableDisplays.map((d) {
                              final isConnected =
                                  state.connectedDisplayId == d.id;
                              final primaryColor = Theme.of(
                                context,
                              ).colorScheme.primary;
                              return ListTile(
                                leading: Icon(
                                  isConnected
                                      ? Icons.monitor
                                      : Icons.monitor_outlined,
                                  color: isConnected ? primaryColor : null,
                                ),
                                title: Text(d.name),
                                subtitle: Text('ID: ${d.id}'),
                                trailing: isConnected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: primaryColor,
                                      )
                                    : FilledButton.tonal(
                                        onPressed: () =>
                                            cubit.connect(d.id, d.name),
                                        child: Text(l10n.displayConnect),
                                      ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],

                  if (state.enabled && _isSupported) ...[
                    const SizedBox(height: 16),
                    _Section(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle(l10n.displayStatus),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                _StatusDot(connected: state.isConnected),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.isConnected
                                        ? l10n.displayConnected(state.connectedDisplayName ?? 'Display ${state.connectedDisplayId}')
                                        : l10n.displayNotConnected,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),

                            if (state.status == DisplayStatus.error &&
                                state.errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                state.errorMessage!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            ],

                            if (state.isConnected) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.tonal(
                                      onPressed: () => cubit.reconnect(),
                                      child: Text(l10n.displayReconnect),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => cubit.disconnect(),
                                      child: Text(l10n.displayDisconnect),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Thin card wrapper for settings sections.
class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(margin: EdgeInsets.zero, child: child);
  }
}

/// Primary-coloured section heading shared across settings cards.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Small coloured dot indicating connection status.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: connected ? Colors.green : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
