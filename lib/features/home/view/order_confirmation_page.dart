import 'package:atomikpos/features/home/bloc/home_bloc.dart';
import 'package:atomikpos/features/home/bloc/home_event.dart';
import 'package:atomikpos/features/home/bloc/home_state.dart';
import 'package:atomikpos/features/home/view/widgets/numeric_input_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final total = state.cartItems.fold<double>(
          0,
          (sum, item) => sum + (item.product.price * item.quantity),
        );

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: kToolbarHeight + 16.0,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('Order List'),
            centerTitle: false,
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                ),
                onPressed: () => _confirmClearOrder(context),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Clear Order',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(width: 8),
            ],
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
              padding: const EdgeInsets.all(16),
              itemCount: state.cartItems.length,
              itemBuilder: (context, index) {
                final item = state.cartItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      NumericInputGroup(
                        value: item.quantity.toInt(),
                        onChanged: (newQty) {
                          context.read<HomeBloc>().add(
                            HomeCartQuantityUpdated(
                              item.product,
                              newQty.toDouble(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(
                                    item.product.price * item.quantity,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No additions',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(0),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: _BottomActionButtons(
            onClear: () => _confirmClearOrder(context),
            onConfirm: () {
              // TODO: Finish order
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmClearOrder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Order?'),
        content: const Text(
          'Are you sure you want to remove all items from the order list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Clear Order',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) {
        // Wait for dialog closing animation to finish
        await Future.delayed(const Duration(milliseconds: 300));
        if (context.mounted) {
          context.read<HomeBloc>().add(HomeCartCleared());
          context.go('/');
        }
      }
    }
  }
}

class _BottomActionButtons extends StatelessWidget {
  const _BottomActionButtons({required this.onClear, required this.onConfirm});

  final VoidCallback onClear;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
      ),
      child: SizedBox(
        height: kToolbarHeight + 16.0,
        child: Row(
          children: [
            IconButton(
              onPressed: onClear,
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              icon: SizedBox(
                width: kToolbarHeight + 16.0,
                height: double.infinity,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
            ),
            VerticalDivider(
              width: 1,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            Expanded(
              child: SizedBox(
                height: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Proceed to Payment',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
