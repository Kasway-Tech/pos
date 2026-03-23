import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasway/app/constants/preference_keys.dart';
import 'package:kasway/app/donation/donation_cubit.dart';
import 'package:kasway/app/donation/donation_state.dart';
import 'package:kasway/app/helpers/format_helpers.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/wallet/wallet_cubit.dart';
import 'package:kasway/app/widgets/explorer_page.dart';
import 'package:kasway/data/repositories/donation_repository.dart';
import 'package:kasway/data/services/kaspa_wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  int _historyKey = 0;

  void _onDonated() => setState(() => _historyKey++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.donateTitle), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              _OneTimeDonationSection(onDonated: _onDonated),
              const SizedBox(height: 24),
              const _AutoDonateSection(),
              const SizedBox(height: 24),
              _DonationHistorySection(key: ValueKey(_historyKey)),
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
  const _OneTimeDonationSection({required this.onDonated});

  final VoidCallback onDonated;

  static String _truncate(String addr) {
    if (addr.length <= 24) return addr;
    return '${addr.substring(0, 14)}…${addr.substring(addr.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, networkState) {
        final devAddress = DonationConstants.addressForHrp(
          networkState.addressHrp,
        );
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
                      context.l10n.donateSupportDeveloper,
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.donateSupportDeveloperBody,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _truncate(devAddress),
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
                          Clipboard.setData(ClipboardData(text: devAddress));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.donateAddressCopied),
                              duration: const Duration(seconds: 2),
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
                    label: Text(context.l10n.donateDonateNow),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDonateSheet(BuildContext context) {
    final networkState = context.read<NetworkCubit>().state;
    final hrp = networkState.addressHrp;
    final network = networkState.network.name;
    final balanceKas = context.read<WalletCubit>().state.balanceKas;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _OneTimeDonateSheet(
        hrp: hrp,
        network: network,
        balanceKas: balanceKas,
        onDonated: onDonated,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// One-time donate bottom sheet
// ---------------------------------------------------------------------------

class _OneTimeDonateSheet extends StatefulWidget {
  const _OneTimeDonateSheet({
    required this.hrp,
    required this.network,
    required this.balanceKas,
    required this.onDonated,
  });

  final String hrp;
  final String network;
  final double balanceKas;
  final VoidCallback onDonated;

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

    final activeUrl = context.read<NetworkCubit>().state.activeUrl;
    final donationRepo = context.read<DonationRepository>();
    final noWalletMsg = context.l10n.donateNoWallet;

    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString(PreferenceKeys.walletMnemonic) ?? '';
    if (mnemonic.isEmpty) {
      _showError(noWalletMsg);
      return;
    }
    final kasAmount = double.tryParse(_amountController.text.trim()) ?? 0;
    final amountSompi = (kasAmount * 1e8).toInt();
    final payloadNote =
        'kasway:donate:${DateTime.now().toUtc().toIso8601String()}:${kasAmount.toStringAsFixed(4)}kas';

    setState(() => _submitting = true);

    final result = await KaspaWalletService().sendTransaction(
      mnemonic: mnemonic,
      toAddress: DonationConstants.addressForHrp(widget.hrp),
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
      await donationRepo.recordDonation(
        txId: result.txId,
        amountKas: kasAmount,
        isAuto: false,
        network: widget.network,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.donateThankYou(result.txId)),
          duration: const Duration(seconds: 6),
        ),
      );
      widget.onDonated();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.donateTransactionFailed),
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
    final l10n = context.l10n;
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
              l10n.donateKas,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.donateRecipient(truncateAddress(DonationConstants.addressForHrp(widget.hrp), visibleEnd: 8)),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.donateAvailable(formatKas(widget.balanceKas)),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.donateAmountLabel,
                hintText: '0.00',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.donateAmountRequired;
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) return l10n.donateAmountInvalid;
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.donateSend),
            ),
          ],
        ),
      ),
    );
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
                  context.l10n.donateAutoPerPayment,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.donateAutoPerPaymentBody,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.donateEnableAuto),
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
                        _valueController.text = state.percentageValue
                            .toString();
                      } else {
                        _valueController.text = state.fixedKasAmount.toString();
                      }
                      context.read<DonationCubit>().setMode(v);
                    },
                    child: Column(
                      children: [
                        RadioListTile<DonationMode>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.l10n.donatePercentage),
                          value: DonationMode.percentage,
                        ),
                        RadioListTile<DonationMode>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.l10n.donateFixed),
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
                          ? context.l10n.donatePercentageLabel
                          : context.l10n.donateAmountKasLabel,
                      hintText: '1.0',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _save(context, state),
                      child: Text(context.l10n.donateSaveSettings),
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
        SnackBar(content: Text(context.l10n.donateInvalidValue)),
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
      SnackBar(
        content: Text(context.l10n.donateSettingsSaved),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section C — Donation History
// ---------------------------------------------------------------------------

class _DonationHistorySection extends StatefulWidget {
  const _DonationHistorySection({super.key});

  @override
  State<_DonationHistorySection> createState() =>
      _DonationHistorySectionState();
}

class _DonationHistorySectionState extends State<_DonationHistorySection> {
  late Future<List<DonationRecord>> _future;

  @override
  void initState() {
    super.initState();
    final network = context.read<NetworkCubit>().state.network.name;
    _future = context.read<DonationRepository>().getDonations(network);
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
                Icon(Icons.history, color: colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  context.l10n.donateHistory,
                  style: textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<DonationRecord>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final records = snapshot.data ?? [];
                if (records.isEmpty) {
                  return Text(
                    context.l10n.donateNoDonations,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (int i = 0; i < records.length; i++) ...[
                      _DonationRow(record: records[i]),
                      if (i < records.length - 1) const Divider(height: 1),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationRow extends StatelessWidget {
  const _DonationRow({required this.record});

  final DonationRecord record;

  static String _truncateTx(String tx) {
    if (tx.length <= 20) return tx;
    return '${tx.substring(0, 10)}…${tx.substring(tx.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final networkState = context.read<NetworkCubit>().state;
    final kasSymbol = networkState.kasSymbol;
    final dateStr = DateFormat('d MMM yyyy, HH:mm').format(record.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${formatKas(record.amountKas)} $kasSymbol',
                      style: textTheme.bodyMedium,
                    ),
                    if (record.isAuto) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'auto',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: record.txId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.donateTxIdCopied),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _truncateTx(record.txId),
                        style: textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.copy_outlined,
                        size: 12,
                        color: colorScheme.outline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_outlined),
            tooltip: context.l10n.withdrawalHistoryViewOnExplorer,
            onPressed: () {
              final url =
                  '${networkState.explorerBaseUrl}${record.txId}';
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExplorerPage(url: url),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
