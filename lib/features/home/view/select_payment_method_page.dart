import 'package:atomikpos/features/home/bloc/home_bloc.dart';
import 'package:atomikpos/features/home/bloc/home_event.dart';
import 'package:atomikpos/features/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SelectPaymentMethodPage extends StatelessWidget {
  const SelectPaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
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
          icon: const Icon(Icons.arrow_back),
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

          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ),
            ),
            child: ListView.builder(
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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.outline,
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
                                const CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        title: Text(
                          method.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          if (method.name == 'Cash') {
                            final confirmed1 = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Payment'),
                                content: Text(
                                  'Has the customer handed over the money of $formattedTotal to you?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Yes, Received'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed1 == true) {
                              if (!context.mounted) return;

                              // Wait for original dialog to close completely
                              await Future.delayed(
                                const Duration(milliseconds: 300),
                              );

                              if (!context.mounted) return;
                              final confirmed2 = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Check Amount'),
                                  content: Text(
                                    'Please check the amount $formattedTotal carefully for one last time before proceeding.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Proceed'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed2 == true) {
                                if (!context.mounted) return;
                                context.read<HomeBloc>().add(HomeCartCleared());
                                context.go('/payment-success');
                              }
                            }
                          } else {
                            // TODO: Handle other payment methods
                          }
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          );
        },
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
