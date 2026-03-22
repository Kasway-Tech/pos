import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/network/node_status_cubit.dart';
import 'package:kasway/app/network/node_status_state.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/widgets/pulse_display.dart';

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
  bool _urlsExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final networkState = context.read<NetworkCubit>().state;
    _mainnetUrlController = TextEditingController(
      text: networkState.mainnetCustomUrl ?? '',
    );
    _testnet10UrlController = TextEditingController(
      text: networkState.testnet10CustomUrl ?? '',
    );
    // Rebuild when controller text changes so suffix icons update.
    _mainnetUrlController.addListener(() => setState(() {}));
    _testnet10UrlController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mainnetUrlController.dispose();
    _testnet10UrlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrls() async {
    final cubit = context.read<NetworkCubit>();
    final mainnet = _mainnetUrlController.text.trim();
    final testnet = _testnet10UrlController.text.trim();
    if (mainnet.isNotEmpty) await cubit.setCustomMainnetUrl(mainnet);
    if (testnet.isNotEmpty) await cubit.setCustomTestnet10Url(testnet);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.networkSaved),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _resetToAuto(KaspaNetwork network) async {
    await context.read<NetworkCubit>().resetToAuto(network);
    if (network == KaspaNetwork.mainnet) {
      _mainnetUrlController.clear();
    } else {
      _testnet10UrlController.clear();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.networkResetToAutoSnackbar),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkCubit, NetworkState>(
      listenWhen: (prev, curr) =>
          prev.activeUrl != curr.activeUrl ||
          prev.isAutoMode != curr.isAutoMode ||
          prev.activeResolvedUrl != curr.activeResolvedUrl,
      listener: (context, state) {
        _mainnetUrlController.text = state.mainnetCustomUrl ?? '';
        _testnet10UrlController.text = state.testnet10CustomUrl ?? '';
      },
      child: BlocListener<NodeStatusCubit, NodeStatusState>(
        listenWhen: (prev, curr) => prev.daaScore != curr.daaScore,
        listener: (context, _) => _pulseController.forward(from: 0),
        child: Scaffold(
          appBar: BlurAppBar(
              title: Text(context.l10n.networkTitle), centerTitle: true),
          body: BlocBuilder<NetworkCubit, NetworkState>(
            builder: (context, networkState) {
              return BlocBuilder<NodeStatusCubit, NodeStatusState>(
                builder: (context, nodeState) {
                  final l10n = context.l10n;
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
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
                          _SectionLabel(l10n.networkActiveNetwork),
                          const SizedBox(height: 10),
                          Card(
                            margin: EdgeInsets.zero,
                            child: Column(
                              children: [
                                _NetworkOption(
                                  label: l10n.networkMainnet,
                                  subtitle: l10n.networkMainnetSubtitle,
                                  selected: networkState.network ==
                                      KaspaNetwork.mainnet,
                                  onTap: () => context
                                      .read<NetworkCubit>()
                                      .setNetwork(KaspaNetwork.mainnet),
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                _NetworkOption(
                                  label: l10n.networkTestnet10,
                                  subtitle: l10n.networkTestnet10Subtitle,
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
                          _SectionLabel(l10n.networkNodeStatus),
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
                                            ? l10n.networkConnected
                                            : l10n.networkDisconnected,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: nodeState.connected
                                              ? Colors.green
                                              : colorScheme.error,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (nodeState.lastUpdated.isNotEmpty)
                                        Text(
                                          nodeState.lastUpdated,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.outline,
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
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: colorScheme.error),
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
                                          style: theme.textTheme.displaySmall
                                              ?.copyWith(
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Center(
                                    child: Text(
                                      l10n.networkVirtualDaaScore,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(color: colorScheme.outline),
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
                                  title: Text(
                                    l10n.networkCustomNodeUrls,
                                    style: const TextStyle(
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

                                  // Mode indicator row
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          networkState.isAutoMode
                                              ? Icons.auto_awesome_outlined
                                              : Icons.edit_outlined,
                                          size: 16,
                                          color: colorScheme.outline,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          networkState.isAutoMode
                                              ? l10n.networkAutoMode
                                              : l10n.networkCustomMode,
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                  color: colorScheme.outline),
                                        ),
                                        if (!networkState.isAutoMode) ...[
                                          const Spacer(),
                                          TextButton(
                                            onPressed: () => _resetToAuto(
                                                networkState.network),
                                            child:
                                                Text(l10n.networkResetToAuto),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Resolved URL display (auto mode only)
                                  if (networkState.isAutoMode)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 4, 16, 8),
                                      child: networkState.activeResolvedUrl !=
                                              null
                                          ? Text(
                                              l10n.networkResolvedNode(
                                                  networkState
                                                      .activeResolvedUrl!),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: colorScheme.outline,
                                                fontFeatures: const [
                                                  FontFeature.tabularFigures(),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Row(
                                              children: [
                                                const SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 1.5),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  l10n.networkResolving,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                          color:
                                                              colorScheme.outline),
                                                ),
                                              ],
                                            ),
                                    ),

                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 8, 16, 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TextField(
                                          controller: _mainnetUrlController,
                                          decoration: InputDecoration(
                                            labelText: l10n.networkMainnetUrl,
                                            hintText: 'wss://…',
                                            border:
                                                const OutlineInputBorder(),
                                            isDense: true,
                                            suffixIcon:
                                                _mainnetUrlController
                                                        .text.isNotEmpty
                                                    ? IconButton(
                                                        icon: const Icon(
                                                            Icons.close,
                                                            size: 18),
                                                        onPressed: () =>
                                                            _resetToAuto(
                                                                KaspaNetwork
                                                                    .mainnet),
                                                      )
                                                    : null,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: _testnet10UrlController,
                                          decoration: InputDecoration(
                                            labelText:
                                                l10n.networkTestnet10Url,
                                            hintText: 'wss://…',
                                            border:
                                                const OutlineInputBorder(),
                                            isDense: true,
                                            suffixIcon:
                                                _testnet10UrlController
                                                        .text.isNotEmpty
                                                    ? IconButton(
                                                        icon: const Icon(
                                                            Icons.close,
                                                            size: 18),
                                                        onPressed: () =>
                                                            _resetToAuto(
                                                                KaspaNetwork
                                                                    .testnet10),
                                                      )
                                                    : null,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        FilledButton(
                                          onPressed: _saveUrls,
                                          child: Text(l10n.networkSave),
                                        ),
                                      ],
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
        color: connected
            ? Colors.green
            : Theme.of(context).colorScheme.error,
      ),
    );
  }
}
