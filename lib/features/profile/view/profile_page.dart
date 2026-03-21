import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/wallet/wallet_cubit.dart';
import 'package:kasway/app/wallet/wallet_state.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/widgets/explorer_page.dart';
import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/repositories/withdrawal_repository.dart';
import 'package:kasway/data/services/kaspa_wallet_service.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/home/view/payment_successful_page.dart';
import 'package:kasway/features/items/view/item_management_page.dart';
import 'package:kasway/app/constants/preference_keys.dart';
import 'package:kasway/app/helpers/format_helpers.dart';
import 'package:kasway/features/profile/view/data_transfer_page.dart';
import 'package:kasway/features/profile/view/display_settings_page.dart';
import 'package:kasway/features/profile/view/donation_page.dart';
import 'package:kasway/features/profile/view/network_page.dart';
import 'package:kasway/features/profile/view/order_history_page.dart';
import 'package:kasway/features/profile/view/settings_page.dart';
import 'package:kasway/features/profile/view/table_layout_page.dart';
import 'package:kasway/features/profile/view/theme_settings_page.dart';
import 'package:kasway/features/profile/view/withdrawal_history_page.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Profile section enum
// ---------------------------------------------------------------------------

enum _ProfileSection {
  orders,
  items,
  tableLayout,
  dataTransfer,
  network,
  display,
  theme,
  settings,
  donate,
  withdrawals,
}

extension _ProfileSectionWidget on _ProfileSection {
  Widget build() => switch (this) {
        _ProfileSection.orders => const OrderHistoryPage(),
        _ProfileSection.items => const ItemManagementPage(),
        _ProfileSection.tableLayout => const TableLayoutPage(),
        _ProfileSection.dataTransfer => const DataTransferPage(),
        _ProfileSection.network => const NetworkPage(),
        _ProfileSection.display => const DisplaySettingsPage(),
        _ProfileSection.theme => const ThemeSettingsPage(),
        _ProfileSection.settings => const SettingsPage(),
        _ProfileSection.donate => const DonationPage(),
        _ProfileSection.withdrawals => const WithdrawalHistoryPage(),
      };
}

// ---------------------------------------------------------------------------
// ProfilePage
// ---------------------------------------------------------------------------

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  _ProfileSection? _activeSection;

  bool _isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 720;

  void _openSection(_ProfileSection section) =>
      setState(() => _activeSection = section);

  @override
  Widget build(BuildContext context) {
    return _isWide(context) ? _buildWide(context) : _buildNarrow(context);
  }

  // ---- Narrow layout (mobile / portrait tablet) --------------------------

  Widget _buildNarrow(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: BlurAppBar(title: const Text('Profile'), centerTitle: true),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              children: [
                const _WalletCard(),
                const SizedBox(height: 32.0),
                ..._menuItems(context, isWide: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- Wide layout (landscape tablet / desktop) --------------------------

  Widget _buildWide(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left panel — 4 parts
            Expanded(
              flex: 4,
              child: Scaffold(
                appBar:
                    BlurAppBar(title: const Text('Profile'), centerTitle: true),
                body: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  children: [
                    _WalletCard(
                      onHistoryTap: () =>
                          _openSection(_ProfileSection.withdrawals),
                    ),
                    const SizedBox(height: 32.0),
                    ..._menuItems(context, isWide: true),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            // Right panel — 6 parts
            Expanded(
              flex: 6,
              child: _buildDetail(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail() {
    if (_activeSection == null) return const _DetailPlaceholder();
    // A nested Navigator whose only initial route is the sub-page.
    // Because the stack has exactly one entry, Navigator.canPop() == false
    // and automaticallyImplyLeading never renders a back button.
    // The key ensures a fresh Navigator (and fresh sub-page state) each time
    // the active section changes.
    return Navigator(
      key: ValueKey(_activeSection),
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => _activeSection!.build(),
      ),
    );
  }

  // ---- Shared menu items -------------------------------------------------

  List<Widget> _menuItems(BuildContext context, {required bool isWide}) {
    void navigate(_ProfileSection section, String route) {
      if (isWide) {
        _openSection(section);
      } else {
        context.push(route);
      }
    }

    bool isSelected(_ProfileSection section) =>
        isWide && _activeSection == section;

    return [
      _ProfileMenuItem(
        icon: Icons.history,
        title: 'Order History',
        isSelected: isSelected(_ProfileSection.orders),
        onTap: () => navigate(_ProfileSection.orders, '/profile/orders'),
      ),
      _ProfileMenuItem(
        icon: Icons.inventory_2_outlined,
        title: 'Manage Item',
        isSelected: isSelected(_ProfileSection.items),
        onTap: () => navigate(_ProfileSection.items, '/profile/items'),
      ),
      _ProfileMenuItem(
        icon: Icons.table_restaurant_outlined,
        title: 'Table Layout',
        isSelected: isSelected(_ProfileSection.tableLayout),
        onTap: () => context.push('/profile/table-layout'),
      ),
      _ProfileMenuItem(
        icon: Icons.restore_outlined,
        title: 'Backup & Restore',
        isSelected: isSelected(_ProfileSection.dataTransfer),
        onTap: () =>
            navigate(_ProfileSection.dataTransfer, '/profile/data-transfer'),
      ),
      _ProfileMenuItem(
        icon: Icons.lan_outlined,
        title: 'Network & Node',
        isSelected: isSelected(_ProfileSection.network),
        onTap: () => navigate(_ProfileSection.network, '/profile/network'),
      ),
      _ProfileMenuItem(
        icon: Icons.tv_outlined,
        title: 'Display',
        isSelected: isSelected(_ProfileSection.display),
        onTap: () => navigate(_ProfileSection.display, '/profile/display'),
      ),
      _ProfileMenuItem(
        icon: Icons.palette_outlined,
        title: 'Theme Settings',
        isSelected: isSelected(_ProfileSection.theme),
        onTap: () => navigate(_ProfileSection.theme, '/profile/theme'),
      ),
      _ProfileMenuItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        isSelected: isSelected(_ProfileSection.settings),
        onTap: () => navigate(_ProfileSection.settings, '/profile/settings'),
      ),
      _ProfileMenuItem(
        icon: Icons.favorite_outline,
        title: 'Donate',
        isSelected: isSelected(_ProfileSection.donate),
        onTap: () => navigate(_ProfileSection.donate, '/profile/donate'),
      ),
      const Divider(height: 32.0),
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
    ];
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
// Detail placeholder (shown when nothing is selected in wide layout)
// ---------------------------------------------------------------------------

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a section',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wallet Card
// ---------------------------------------------------------------------------

class _WalletCard extends StatelessWidget {
  const _WalletCard({this.onHistoryTap});

  /// If provided, used instead of `context.push('/profile/withdrawals')`.
  final VoidCallback? onHistoryTap;

  void _showWithdrawSheet(BuildContext context, String address) {
    final withdrawalRepo = context.read<WithdrawalRepository>();
    final kasIdrRate =
        context.read<CurrencyCubit>().state.exchangeRates['idr'] ?? 0.0;
    final networkState = context.read<NetworkCubit>().state;
    final hrp = networkState.addressHrp;
    final activeUrl = networkState.activeUrl;
    final network = networkState.network.name;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _WithdrawSheet(
        fromAddress: address,
        withdrawalRepository: withdrawalRepo,
        kasIdrRate: kasIdrRate,
        hrp: hrp,
        activeUrl: activeUrl,
        network: network,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (prev, curr) =>
          prev.cartItems.isNotEmpty && curr.cartItems.isEmpty,
      listener: (context, _) => context.read<WalletCubit>().refreshBalance(),
      child: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, walletState) {
          final address = walletState.address;
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
                              Text(
                                address.isEmpty
                                    ? 'No wallet configured'
                                    : truncateAddress(address),
                                style: textTheme.bodyMedium?.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  color: address.isEmpty
                                      ? colorScheme.outline
                                      : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (address.isNotEmpty) ...[
                          IconButton(
                            icon: const Icon(Icons.copy_outlined),
                            tooltip: 'Copy address',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: address));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address copied'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.open_in_browser_outlined),
                            tooltip: 'View in explorer',
                            onPressed: () {
                              final url =
                                  '${context.read<NetworkCubit>().state.explorerAddressBaseUrl}$address';
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ExplorerPage(url: url),
                              ));
                            },
                          ),
                        ],
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
                    _RevenuePriceDisplay(kasBalance: walletState.balanceKas),

                    const SizedBox(height: 16),

                    // --- History + Withdraw buttons ---
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: onHistoryTap ??
                                () => context.push('/profile/withdrawals'),
                            child: const Text('History'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: address.isEmpty
                                ? null
                                : () => _showWithdrawSheet(context, address),
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
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dual-currency revenue display
// ---------------------------------------------------------------------------

class _RevenuePriceDisplay extends StatelessWidget {
  const _RevenuePriceDisplay({required this.kasBalance});

  /// Real on-chain KAS balance (sum of UTXOs, in KAS not sompi).
  final double kasBalance;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, networkState) {
        return BlocBuilder<CurrencyCubit, CurrencyState>(
          builder: (context, state) =>
              _buildContent(context, state, networkState),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    CurrencyState state,
    NetworkState networkState,
  ) {
    final kasSymbol = networkState.kasSymbol;
    final kasStr = '$kasSymbol ${formatKas(kasBalance)}';

    final textTheme = Theme.of(context).textTheme;
    final boldHeadline =
        textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);
    final subStyle = textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.outline);

    if (state.selectedCurrency.isCrypto) {
      return Text(kasStr, style: boldHeadline);
    } else {
      // Convert KAS → IDR → selected fiat for display.
      final kasIdr = state.exchangeRates['idr'] ?? 0.0;
      final idrValue = kasBalance * kasIdr;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kasIdr > 0
              ? PriceText(idrValue, style: boldHeadline)
              : Text(kasStr, style: boldHeadline),
          Text('≈ $kasStr', style: subStyle),
        ],
      );
    }
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
    required this.hrp,
    required this.activeUrl,
    required this.network,
  });

  final String fromAddress;
  final WithdrawalRepository withdrawalRepository;
  final double kasIdrRate;
  final String hrp;
  final String activeUrl;
  final String network;

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

    final nav = Navigator.of(context); // capture before any async gap

    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString(PreferenceKeys.walletMnemonic) ?? '';
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
      hrp: widget.hrp,
      activeUrl: widget.activeUrl,
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
        network: widget.network,
        createdAt: DateTime.now(),
      );
      if (!mounted) return;
      context.read<WalletCubit>().refreshBalance();
      setState(() => _submitting = false);
      nav.pop();
      nav.push(MaterialPageRoute(
        builder: (_) => const PaymentSuccessfulPage(),
      ));
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
    final kasSymbol = context.watch<NetworkCubit>().state.kasSymbol;
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
              'Withdraw $kasSymbol',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _toAddressController,
              decoration: InputDecoration(
                labelText: 'Destination Kaspa Address',
                hintText: '${widget.hrp}:q...',
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Address is required';
                if (!v.trim().startsWith('${widget.hrp}:')) {
                  return 'Must be a valid ${widget.hrp}: address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount ($kasSymbol)',
                hintText: '0.00',
                border: const OutlineInputBorder(),
                suffixIcon: TextButton(
                  onPressed: () {
                    // Read live balance — never use a stale snapshot.
                    // Fee estimate: 0.001 KAS covers up to ~89 inputs for a
                    // max-send (1 output), where storage mass ≈ 0.
                    final liveBalance =
                        context.read<WalletCubit>().state.balanceKas;
                    const feeKas = 0.001;
                    final max =
                        (liveBalance - feeKas).clamp(0.0, double.infinity);
                    final formatted = max
                        .toStringAsFixed(8)
                        .replaceAll(RegExp(r'0+$'), '')
                        .replaceAll(RegExp(r'\.$'), '.00');
                    _amountController.text = formatted;
                  },
                  child: const Text('Max'),
                ),
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
    this.isSelected = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
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
