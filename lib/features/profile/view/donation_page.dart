import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/donation/donation_cubit.dart';
import 'package:kasway/app/donation/donation_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/wallet/wallet_cubit.dart';
import 'package:kasway/data/services/kaspa_wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlurAppBar(title: const Text('Donate'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: const [
              _OneTimeDonationSection(),
              SizedBox(height: 24),
              _AutoDonateSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section A — One-time Donation
// ---------------------------------------------------------------------------

class _OneTimeDonationSection extends StatelessWidget {
  const _OneTimeDonationSection();

  static String _truncate(String addr) {
    if (addr.length <= 24) return addr;
    return '${addr.substring(0, 14)}…${addr.substring(addr.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Support the Developer',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Kasway is free and open source. If you find it useful, consider sending a one-time KAS donation directly to the developer.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _truncate(DonationConstants.address),
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      Clipboard.setData(
                          const ClipboardData(text: DonationConstants.address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address copied'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.copy_outlined, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openDonateSheet(context),
                icon: const Icon(Icons.send_outlined),
                label: const Text('Donate Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDonateSheet(BuildContext context) {
    final hrp = context.read<NetworkCubit>().state.addressHrp;
    final balanceKas = context.read<WalletCubit>().state.balanceKas;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _OneTimeDonateSheet(hrp: hrp, balanceKas: balanceKas),
    );
  }
}

// ---------------------------------------------------------------------------
// One-time donate bottom sheet
// ---------------------------------------------------------------------------

class _OneTimeDonateSheet extends StatefulWidget {
  const _OneTimeDonateSheet({required this.hrp, required this.balanceKas});

  final String hrp;
  final double balanceKas;

  @override
  State<_OneTimeDonateSheet> createState() => _OneTimeDonateSheetState();
}

class _OneTimeDonateSheetState extends State<_OneTimeDonateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.hrp != 'kaspa') {
      _showError('Donations are only available on mainnet.');
      return;
    }

    final activeUrl = context.read<NetworkCubit>().state.activeUrl;

    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString('wallet_mnemonic') ?? '';
    if (mnemonic.isEmpty) {
      _showError('No wallet mnemonic found. Please set up your wallet first.');
      return;
    }
    final kasAmount = double.tryParse(_amountController.text.trim()) ?? 0;
    final amountSompi = (kasAmount * 1e8).toInt();
    final payloadNote =
        'kasway:donate:${DateTime.now().toUtc().toIso8601String()}:${kasAmount.toStringAsFixed(4)}kas';

    setState(() => _submitting = true);

    final result = await KaspaWalletService().sendTransaction(
      mnemonic: mnemonic,
      toAddress: DonationConstants.address,
      amountSompi: amountSompi,
      payloadNote: payloadNote,
      hrp: widget.hrp,
      activeUrl: activeUrl,
    );

    if (!mounted) return;

    if (result.error.isNotEmpty) {
      setState(() => _submitting = false);
      _showError(result.error);
    } else {
      setState(() => _submitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you! TX: ${result.txId}'),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transaction Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMainnet = widget.hrp == 'kaspa';
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Donate KAS',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Recipient: ${_truncateAddr(DonationConstants.address)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Available: ${_formatKas(widget.balanceKas)} KAS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 20),
            if (!isMainnet)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Donations are only available on mainnet.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error),
                ),
              ),
            TextFormField(
              controller: _amountController,
              enabled: isMainnet,
              decoration: const InputDecoration(
                labelText: 'Amount (KAS)',
                hintText: '0.00',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: (_submitting || !isMainnet) ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  static String _truncateAddr(String addr) {
    if (addr.length <= 24) return addr;
    return '${addr.substring(0, 14)}…${addr.substring(addr.length - 8)}';
  }

  static String _formatKas(double kas) {
    final s = kas.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
    return s.endsWith('.') ? '${s}00' : s;
  }
}

// ---------------------------------------------------------------------------
// Section B — Auto-Donate Per Transaction
// ---------------------------------------------------------------------------

class _AutoDonateSection extends StatefulWidget {
  const _AutoDonateSection();

  @override
  State<_AutoDonateSection> createState() => _AutoDonateSectionState();
}

class _AutoDonateSectionState extends State<_AutoDonateSection> {
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController();
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonationCubit, DonationState>(
      builder: (context, state) {
        // Sync controller text with state when not focused
        final current = state.mode == DonationMode.percentage
            ? state.percentageValue.toString()
            : state.fixedKasAmount.toString();
        if (!_valueController.value.composing.isValid &&
            _valueController.text.isEmpty) {
          _valueController.text = current;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Donate Per Payment',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Silently send a small KAS amount to the developer after each confirmed customer payment (mainnet only).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Auto-Donate'),
                  value: state.autoEnabled,
                  onChanged: (v) =>
                      context.read<DonationCubit>().setAutoEnabled(v),
                ),
                if (state.autoEnabled) ...[
                  const Divider(height: 16),
                  RadioGroup<DonationMode>(
                    groupValue: state.mode,
                    onChanged: (v) {
                      if (v == null) return;
                      if (v == DonationMode.percentage) {
                        _valueController.text =
                            state.percentageValue.toString();
                      } else {
                        _valueController.text =
                            state.fixedKasAmount.toString();
                      }
                      context.read<DonationCubit>().setMode(v);
                    },
                    child: Column(
                      children: [
                        RadioListTile<DonationMode>(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Percentage of transaction'),
                          value: DonationMode.percentage,
                        ),
                        RadioListTile<DonationMode>(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Fixed amount (KAS)'),
                          value: DonationMode.fixedAmount,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _valueController,
                    decoration: InputDecoration(
                      labelText: state.mode == DonationMode.percentage
                          ? 'Percentage (%)'
                          : 'Amount (KAS)',
                      hintText: state.mode == DonationMode.percentage
                          ? '1.0'
                          : '1.0',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _save(context, state),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _save(BuildContext context, DonationState state) {
    final raw = double.tryParse(_valueController.text.trim()) ?? 0;
    if (raw <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid value greater than 0')),
      );
      return;
    }
    final cubit = context.read<DonationCubit>();
    if (state.mode == DonationMode.percentage) {
      cubit.setPercentage(raw);
    } else {
      cubit.setFixedAmount(raw);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auto-donate settings saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
