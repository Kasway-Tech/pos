import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SelectPaymentMethodPage extends StatelessWidget {
  const SelectPaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Container(
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
                        color: Theme.of(context).colorScheme.surfaceContainer,
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
                    onTap: () {
                      // TODO: Handle payment method selection
                    },
                  );
                }),
              ],
            );
          },
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
