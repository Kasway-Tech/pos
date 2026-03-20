import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/network/node_status_cubit.dart';
import 'package:kasway/app/network/node_status_state.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/widgets/pulse_display.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage>
    with SingleTickerProviderStateMixin {
  // Animation only — all connection logic lives in NodeStatusCubit.
  late final AnimationController _pulseController;

  late final TextEditingController _mainnetUrlController;
  late final TextEditingController _testnet10UrlController;
  final _formKey = GlobalKey<FormState>();
  bool _urlsExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final networkState = context.read<NetworkCubit>().state;
    _mainnetUrlController =
        TextEditingController(text: networkState.mainnetUrl);
    _testnet10UrlController =
        TextEditingController(text: networkState.testnet10Url);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mainnetUrlController.dispose();
    _testnet10UrlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrls() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<NetworkCubit>();
    await cubit.setMainnetUrl(_mainnetUrlController.text.trim());
    await cubit.setTestnet10Url(_testnet10UrlController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved — reconnecting…'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkCubit, NetworkState>(
      listenWhen: (prev, curr) => prev.activeUrl != curr.activeUrl,
      listener: (context, state) {
        _mainnetUrlController.text = state.mainnetUrl;
        _testnet10UrlController.text = state.testnet10Url;
      },
      child: BlocListener<NodeStatusCubit, NodeStatusState>(
        listenWhen: (prev, curr) => prev.daaScore != curr.daaScore,
        listener: (context, _) => _pulseController.forward(from: 0),
        child: TitlebarSafeArea(
          child: Scaffold(
            appBar: BlurAppBar(
              title: const Text('Network'),
              centerTitle: true,
            ),
            body: BlocBuilder<NetworkCubit, NetworkState>(
              builder: (context, networkState) {
                return BlocBuilder<NodeStatusCubit, NodeStatusState>(
                  builder: (context, nodeState) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 540),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          children: [
                            // ── Active Network ──────────────────────────────
                            _SectionLabel('Active Network'),
                            const SizedBox(height: 10),
                            Card(
                              margin: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  _NetworkOption(
                                    label: 'Mainnet',
                                    subtitle: 'Production Kaspa network',
                                    selected: networkState.network ==
                                        KaspaNetwork.mainnet,
                                    onTap: () => context
                                        .read<NetworkCubit>()
                                        .setNetwork(KaspaNetwork.mainnet),
                                  ),
                                  const Divider(
                                      height: 1, indent: 16, endIndent: 16),
                                  _NetworkOption(
                                    label: 'Testnet-10',
                                    subtitle: 'Test network · uses TKAS',
                                    selected: networkState.network ==
                                        KaspaNetwork.testnet10,
                                    onTap: () => context
                                        .read<NetworkCubit>()
                                        .setNetwork(KaspaNetwork.testnet10),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Node Status ─────────────────────────────────
                            _SectionLabel('Node Status'),
                            const SizedBox(height: 10),
                            Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _ConnectionDot(
                                            connected: nodeState.connected),
                                        const SizedBox(width: 8),
                                        Text(
                                          nodeState.connected
                                              ? 'Connected'
                                              : 'Disconnected',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: nodeState.connected
                                                    ? Colors.green
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                              ),
                                        ),
                                        const Spacer(),
                                        if (nodeState.lastUpdated.isNotEmpty)
                                          Text(
                                            nodeState.lastUpdated,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                  fontFeatures: const [
                                                    FontFeature.tabularFigures(),
                                                  ],
                                                ),
                                          ),
                                      ],
                                    ),
                                    if (!nodeState.connected &&
                                        nodeState.error.isNotEmpty &&
                                        nodeState.error != 'Connecting…') ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        nodeState.error,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 56,
                                      child: Center(
                                        child: PulseDisplay(
                                          controller: _pulseController,
                                          child: Text(
                                            nodeState.daaScore,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall
                                                ?.copyWith(
                                                  fontFeatures: const [
                                                    FontFeature.tabularFigures(),
                                                  ],
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Center(
                                      child: Text(
                                        'Virtual DAA Score',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Node URLs (collapsible) ──────────────────────
                            Card(
                              margin: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: const Text(
                                      'Custom Node URLs',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    trailing: Icon(
                                      _urlsExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),
                                    onTap: () => setState(
                                        () => _urlsExpanded = !_urlsExpanded),
                                  ),
                                  if (_urlsExpanded) ...[
                                    const Divider(height: 1),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 16, 16, 20),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            TextFormField(
                                              controller:
                                                  _mainnetUrlController,
                                              decoration:
                                                  const InputDecoration(
                                                labelText:
                                                    'Mainnet WebSocket URL',
                                                hintText: 'wss://…',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                              validator: (v) =>
                                                  (v == null ||
                                                          v.trim().isEmpty)
                                                      ? 'Required'
                                                      : null,
                                            ),
                                            const SizedBox(height: 12),
                                            TextFormField(
                                              controller:
                                                  _testnet10UrlController,
                                              decoration:
                                                  const InputDecoration(
                                                labelText:
                                                    'Testnet-10 WebSocket URL',
                                                hintText: 'wss://…',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                              validator: (v) =>
                                                  (v == null ||
                                                          v.trim().isEmpty)
                                                      ? 'Required'
                                                      : null,
                                            ),
                                            const SizedBox(height: 16),
                                            FilledButton(
                                              onPressed: _saveUrls,
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
    );
  }
}

class _NetworkOption extends StatelessWidget {
  const _NetworkOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? colorScheme.primary : colorScheme.outline,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selected ? colorScheme.primary : null,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionDot extends StatelessWidget {
  const _ConnectionDot({required this.connected});
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: connected ? Colors.green : Theme.of(context).colorScheme.error,
      ),
    );
  }
}

