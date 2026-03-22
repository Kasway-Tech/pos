import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/widgets/macos_title_bar.dart';

class NetworkSettingsPage extends StatefulWidget {
  const NetworkSettingsPage({super.key});

  @override
  State<NetworkSettingsPage> createState() => _NetworkSettingsPageState();
}

class _NetworkSettingsPageState extends State<NetworkSettingsPage> {
  late final TextEditingController _mainnetUrlController;
  late final TextEditingController _testnet10UrlController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = context.read<NetworkCubit>().state;
    _mainnetUrlController =
        TextEditingController(text: state.mainnetCustomUrl ?? '');
    _testnet10UrlController =
        TextEditingController(text: state.testnet10CustomUrl ?? '');
  }

  @override
  void dispose() {
    _mainnetUrlController.dispose();
    _testnet10UrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<NetworkCubit>();
    final mainnet = _mainnetUrlController.text.trim();
    final testnet = _testnet10UrlController.text.trim();
    if (mainnet.isNotEmpty) await cubit.setCustomMainnetUrl(mainnet);
    if (testnet.isNotEmpty) await cubit.setCustomTestnet10Url(testnet);
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return MacOSTitleBar(
      child: Scaffold(
        appBar: BlurAppBar(title: const Text('Network'), centerTitle: true),
        body: BlocBuilder<NetworkCubit, NetworkState>(
          builder: (context, state) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // --- Network selector ---
                      Text(
                        'Active Network',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _NetworkTile(
                        label: 'Mainnet',
                        subtitle: 'Production Kaspa network',
                        selected: state.network == KaspaNetwork.mainnet,
                        onTap: () => context
                            .read<NetworkCubit>()
                            .setNetwork(KaspaNetwork.mainnet),
                      ),
                      const SizedBox(height: 8),
                      _NetworkTile(
                        label: 'Testnet-10',
                        subtitle: 'Test network — uses TKAS',
                        selected: state.network == KaspaNetwork.testnet10,
                        onTap: () => context
                            .read<NetworkCubit>()
                            .setNetwork(KaspaNetwork.testnet10),
                      ),

                      const SizedBox(height: 32),

                      // --- URL customisation ---
                      Text(
                        'Node URLs',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _mainnetUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Mainnet WebSocket URL',
                          hintText: 'wss://…',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _testnet10UrlController,
                        decoration: const InputDecoration(
                          labelText: 'Testnet-10 WebSocket URL',
                          hintText: 'wss://…',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NetworkTile extends StatelessWidget {
  const _NetworkTile({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? colorScheme.primary.withAlpha(20)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? colorScheme.primary : colorScheme.outline,
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
