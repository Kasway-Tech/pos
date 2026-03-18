import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/repositories/order_repository.dart';
import 'package:kasway/data/repositories/withdrawal_repository.dart';
import 'package:kasway/data/services/kaspa_wallet_service.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile'), centerTitle: true),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              children: [
                // Wallet Card Section
                const _WalletCard(),
                const SizedBox(height: 32.0),

                // Menus Section
                _ProfileMenuItem(
                  icon: Icons.history,
                  title: 'Order History',
                  onTap: () => context.push('/profile/orders'),
                ),
                _ProfileMenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Manage Item',
                  onTap: () => context.push('/profile/items'),
                ),
                _ProfileMenuItem(
                  icon: Icons.swap_horiz,
                  title: 'Data Transfer',
                  onTap: () => context.push('/profile/data-transfer'),
                ),
                _ProfileMenuItem(
                  icon: Icons.router,
                  title: 'Node Status',
                  onTap: () => context.push('/profile/node-status'),
                ),
                _ProfileMenuItem(
                  icon: Icons.palette_outlined,
                  title: 'Theme Settings',
                  onTap: () => context.push('/profile/theme'),
                ),
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => context.push('/profile/settings'),
                ),
                _ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => context.push('/profile/help'),
                ),
                const Divider(height: 32.0),

                // Actions Section
                _ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () => _showConfirmationDialog(
                    context,
                    title: 'Logout',
                    content: 'Are you sure you want to log out?',
                    confirmLabel: 'Logout',
                    isDestructive: true,
                  ),
                ),
                _ProfileMenuItem(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () => _showConfirmationDialog(
                    context,
                    title: 'Delete Account',
                    content:
                        'This action is permanent and cannot be undone. All your data will be removed.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(color: isDestructive ? Colors.red : null),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Logic for confirmation would go here
    }
  }
}

// ---------------------------------------------------------------------------
// Wallet Card
// ---------------------------------------------------------------------------

class _WalletCard extends StatefulWidget {
  const _WalletCard();

  @override
  State<_WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<_WalletCard> {
  String _address = '';
  bool _addressLoading = true;
  Future<double>? _balanceFuture;

  @override
  void initState() {
    super.initState();
    _balanceFuture = _loadBalance();
    _loadAddress();
  }

  Future<double> _loadBalance() async {
    final orderRepo = context.read<OrderRepository>();
    final withdrawalRepo = context.read<WithdrawalRepository>();
    final totalRevenue = await orderRepo.getTotalRevenue();
    final totalWithdrawn = await withdrawalRepo.getTotalWithdrawn();
    return totalRevenue - totalWithdrawn;
  }

  Future<void> _loadAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString('wallet_mnemonic') ?? '';
    if (mnemonic.isEmpty) {
      if (mounted) setState(() => _addressLoading = false);
      return;
    }

    final address = await Future.microtask(
      () => KaspaWalletService().deriveAddress(mnemonic),
    );
    if (!mounted) return;
    setState(() {
      _addressLoading = false;
      _address = address;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _truncateAddress(String addr) {
    if (addr.length <= 20) return addr;
    return '${addr.substring(0, 14)}…${addr.substring(addr.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Address row ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kaspa Address',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _addressLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _address.isEmpty
                                    ? 'No wallet configured'
                                    : _truncateAddress(_address),
                                style: textTheme.bodyMedium?.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  color: _address.isEmpty
                                      ? colorScheme.outline
                                      : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                      ],
                    ),
                  ),
                  if (_address.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: 'Copy address',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _address));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Address copied'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                ],
              ),

              const Divider(height: 28),

              // --- Balance ---
              Text(
                'Balance',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 6),
              FutureBuilder<double>(
                future: _balanceFuture,
                builder: (context, snapshot) {
                  return _RevenuePriceDisplay(
                    revenueIdr: snapshot.data ?? 0.0,
                  );
                },
              ),

              const SizedBox(height: 16),

              // --- History + Withdraw buttons ---
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => context.push('/profile/withdrawals'),
                      child: const Text('History'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _address.isEmpty
                          ? null
                          : () => _showWithdrawSheet(context),
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Withdraw'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    final withdrawalRepo = context.read<WithdrawalRepository>();
    final kasIdrRate =
        context.read<CurrencyCubit>().state.exchangeRates['idr'] ?? 0.0;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _WithdrawSheet(
        fromAddress: _address,
        withdrawalRepository: withdrawalRepo,
        kasIdrRate: kasIdrRate,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dual-currency revenue display
// ---------------------------------------------------------------------------

class _RevenuePriceDisplay extends StatelessWidget {
  const _RevenuePriceDisplay({required this.revenueIdr});

  final double revenueIdr;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        final kasIdr = state.exchangeRates['idr'] ?? 0.0;
        final kasAmount = kasIdr > 0 ? revenueIdr / kasIdr : 0.0;
        final kasStr = 'KAS ${kasAmount.toStringAsFixed(4)}';

        final textTheme = Theme.of(context).textTheme;
        final boldHeadline = textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold);
        final subStyle = textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.outline);

        if (state.selectedCurrency.isCrypto) {
          return Text(kasStr, style: boldHeadline);
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PriceText(revenueIdr, style: boldHeadline),
              Text('≈ $kasStr', style: subStyle),
            ],
          );
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Withdraw Bottom Sheet
// ---------------------------------------------------------------------------

class _WithdrawSheet extends StatefulWidget {
  const _WithdrawSheet({
    required this.fromAddress,
    required this.withdrawalRepository,
    required this.kasIdrRate,
  });

  final String fromAddress;
  final WithdrawalRepository withdrawalRepository;
  final double kasIdrRate;

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _formKey = GlobalKey<FormState>();
  final _toAddressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _toAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString('wallet_mnemonic') ?? '';
    if (mnemonic.isEmpty) {
      _showError('No wallet mnemonic found. Please set up your wallet first.');
      return;
    }

    final toAddr = _toAddressController.text.trim();
    final kasAmount = double.tryParse(_amountController.text.trim()) ?? 0;
    final amountSompi = (kasAmount * 1e8).toInt();
    final addrProof = toAddr.length >= 20 ? toAddr.substring(0, 20) : toAddr;
    final payloadNote =
        'kasway:withdraw:${DateTime.now().toUtc().toIso8601String()}:${kasAmount.toStringAsFixed(4)}kas:ack:$addrProof';

    setState(() => _submitting = true);

    final result = await KaspaWalletService().sendTransaction(
      mnemonic: mnemonic,
      toAddress: toAddr,
      amountSompi: amountSompi,
      payloadNote: payloadNote,
    );

    if (!mounted) return;

    if (result.error.isNotEmpty) {
      setState(() => _submitting = false);
      _showError(result.error);
    } else {
      final amountIdr = kasAmount * widget.kasIdrRate;
      await widget.withdrawalRepository.recordWithdrawal(
        txId: result.txId,
        toAddress: toAddr,
        amountKas: kasAmount,
        amountIdr: amountIdr,
        kasIdrRate: widget.kasIdrRate,
        createdAt: DateTime.now(),
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent! TX: ${result.txId}'),
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
              'Withdraw KAS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _toAddressController,
              decoration: const InputDecoration(
                labelText: 'Destination Kaspa Address',
                hintText: 'kaspa:q...',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Address is required';
                if (!v.trim().startsWith('kaspa:')) {
                  return 'Must be a valid kaspa: address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
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
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile Menu Item
// ---------------------------------------------------------------------------

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
