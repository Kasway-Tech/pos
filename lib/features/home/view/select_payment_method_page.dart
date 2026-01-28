import 'package:atomikpos/features/home/bloc/home_bloc.dart';
import 'package:atomikpos/features/home/bloc/home_event.dart';
import 'package:atomikpos/features/home/bloc/home_state.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SelectPaymentMethodPage extends StatefulWidget {
  const SelectPaymentMethodPage({super.key, this.isDialog = false});

  final bool isDialog;

  @override
  State<SelectPaymentMethodPage> createState() =>
      _SelectPaymentMethodPageState();
}

class _SelectPaymentMethodPageState extends State<SelectPaymentMethodPage> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (settings.name) {
              case '/':
                return _PaymentSelectionView(
                  isDialog: widget.isDialog,
                  onSelectMethod: (method) {
                    if (method.name == 'Cash') {
                      _navigatorKey.currentState!.pushNamed(
                        '/cash-confirmation',
                      );
                    } else {
                      // TODO: Handle other payment methods
                    }
                  },
                );
              case '/cash-confirmation':
                return _CashConfirmationView(
                  isDialog: widget.isDialog,
                  onBack: () => _navigatorKey.currentState!.pop(),
                  onNext: () =>
                      _navigatorKey.currentState!.pushNamed('/cash-final'),
                );
              case '/cash-final':
                return _CashFinalConfirmationView(
                  isDialog: widget.isDialog,
                  onBack: () => _navigatorKey.currentState!.pop(),
                  onConfirm: () {
                    context.read<HomeBloc>().add(HomeCartCleared());
                    _navigatorKey.currentState!.pushNamed('/payment-success');
                  },
                );
              case '/payment-success':
                return _PaymentSuccessView(
                  isDialog: widget.isDialog,
                  onDone: () {
                    if (widget.isDialog) {
                      // Close the dialog and return to home
                      Navigator.of(context, rootNavigator: true).pop();
                    } else {
                      context.go('/');
                    }
                  },
                );
              default:
                return const Scaffold(
                  body: Center(child: Text('Unknown route')),
                );
            }
          },
        );
      },
    );
  }
}

class _PaymentSelectionView extends StatelessWidget {
  const _PaymentSelectionView({
    required this.isDialog,
    required this.onSelectMethod,
  });

  final bool isDialog;
  final ValueChanged<_PaymentMethod> onSelectMethod;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );

    final paymentMethods = [
      _PaymentCategory(
        name: 'Cash',
        methods: [
          _PaymentMethod(
            name: 'Cash',
            iconPath: 'assets/svg/payment_methods/cash.svg',
          ),
        ],
      ),
      _PaymentCategory(
        name: 'Cards',
        methods: [
          _PaymentMethod(
            name: 'Debit/Credit Card',
            iconPath: 'assets/svg/payment_methods/card.svg',
          ),
        ],
      ),
      _PaymentCategory(
        name: 'E-Wallets',
        methods: [
          _PaymentMethod(
            name: 'QRIS',
            iconPath: 'assets/svg/payment_methods/qris.svg',
          ),
          _PaymentMethod(
            name: 'Gopay',
            iconPath: 'assets/svg/payment_methods/gopay.svg',
          ),
          _PaymentMethod(
            name: 'ShopeePay',
            iconPath: 'assets/svg/payment_methods/shopee.svg',
          ),
          _PaymentMethod(
            name: 'OVO',
            iconPath: 'assets/svg/payment_methods/ovo.svg',
          ),
          _PaymentMethod(
            name: 'Dana',
            iconPath: 'assets/svg/payment_methods/dana.svg',
          ),
        ],
      ),
      _PaymentCategory(
        name: 'Crypto',
        methods: [
          _PaymentMethod(
            name: 'Kaspa',
            iconPath: 'assets/svg/payment_methods/kaspa.svg',
          ),
          _PaymentMethod(
            name: 'Solana',
            iconPath: 'assets/svg/payment_methods/solana.svg',
          ),
          _PaymentMethod(
            name: 'Bitcoin',
            iconPath: 'assets/svg/payment_methods/bitcoin.svg',
          ),
          _PaymentMethod(
            name: 'Ethereum',
            iconPath: 'assets/svg/payment_methods/ethereum.svg',
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 16.0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(isDialog ? Icons.close : Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Select Payment Method'),
        centerTitle: false,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final total = state.cartItems.fold<double>(
            0,
            (sum, item) => sum + (item.product.price * item.quantity),
          );
          final formattedTotal = currencyFormat.format(total);

          return Column(
            children: [
              if (isDialog)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount to Pay',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        formattedTotal,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    padding: isDialog
                        ? const EdgeInsets.only(bottom: 24)
                        : null,
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, categoryIndex) {
                      final category = paymentMethods[categoryIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                            child: Text(
                              category.name.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          ),
                          ...category.methods.map((method) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 4,
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SvgPicture.asset(
                                  method.iconPath,
                                  placeholderBuilder: (context) =>
                                      const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                ),
                              ),
                              title: Text(
                                method.name,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => onSelectMethod(method),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CashConfirmationView extends StatelessWidget {
  const _CashConfirmationView({
    required this.isDialog,
    required this.onBack,
    required this.onNext,
  });

  final bool isDialog;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final total = state.cartItems.fold<double>(
          0,
          (sum, item) => sum + (item.product.price * item.quantity),
        );
        final formattedTotal = currencyFormat.format(total);

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: kToolbarHeight + 16.0,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
            title: const Text('Cash Payment'),
            centerTitle: false,
          ),
          body: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Amount',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedTotal,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Has the customer handed over the money to you?',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Yes, Received',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(onPressed: onBack, child: const Text('Cancel')),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CashFinalConfirmationView extends StatelessWidget {
  const _CashFinalConfirmationView({
    required this.isDialog,
    required this.onBack,
    required this.onConfirm,
  });

  final bool isDialog;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final total = state.cartItems.fold<double>(
          0,
          (sum, item) => sum + (item.product.price * item.quantity),
        );
        final formattedTotal = currencyFormat.format(total);

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: kToolbarHeight + 16.0,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
            title: const Text('Final Confirmation'),
            centerTitle: false,
          ),
          body: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Check Amount Carefully',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please check the amount $formattedTotal carefully for one last time before proceeding.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirm and Complete',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(onPressed: onBack, child: const Text('Go Back')),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaymentSuccessView extends StatelessWidget {
  const _PaymentSuccessView({required this.isDialog, required this.onDone});

  final bool isDialog;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isDialog
          ? null
          : AppBar(
              toolbarHeight: kToolbarHeight + 16.0,
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              automaticallyImplyLeading: false,
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Bounce(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The transaction has been processed successfully. You can now return to the home screen or start a new order.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final String name;
  final String iconPath;

  _PaymentMethod({required this.name, required this.iconPath});
}

class _PaymentCategory {
  final String name;
  final List<_PaymentMethod> methods;

  _PaymentCategory({required this.name, required this.methods});
}
