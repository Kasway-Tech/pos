import 'package:flutter/material.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Payment Methods')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCardTile(context, 'Visa', '**** **** **** 4242', true),
                  _buildCardTile(
                    context,
                    'Mastercard',
                    '**** **** **** 5555',
                    false,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add New Payment Method'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTile(
    BuildContext context,
    String brand,
    String number,
    bool isDefault,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          brand == 'Visa' ? Icons.credit_card : Icons.credit_card_outlined,
          size: 32,
        ),
        title: Text(brand),
        subtitle: Text(number),
        trailing: isDefault
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
