import 'package:atomikpos/features/home/bloc/home_bloc.dart';
import 'package:atomikpos/features/home/bloc/home_event.dart';
import 'package:atomikpos/features/home/bloc/home_state.dart';
import 'package:atomikpos/features/home/view/widgets/numeric_input_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderSideView extends StatefulWidget {
  const OrderSideView({
    super.key,
    this.onProceedToPayment,
    this.showAppBar = false,
  });

  final VoidCallback? onProceedToPayment;
  final bool showAppBar;

  @override
  State<OrderSideView> createState() => _OrderSideViewState();
}

class _OrderSideViewState extends State<OrderSideView> {
  final ScrollController _scrollController = ScrollController();
  int _previousItemCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Auto-scroll when items are added
        if (state.cartItems.length > _previousItemCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
        _previousItemCount = state.cartItems.length;

        final content = Column(
          children: [
            if (widget.showAppBar)
              AppBar(
                toolbarHeight: kToolbarHeight + 16.0,
                title: const Text('Order List'),
                centerTitle: false,
                scrolledUnderElevation: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
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
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  ),
                ),
                child: state.cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_basket_outlined,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Orders will appear here',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                              item.product.price *
                                                  item.quantity,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
            ),
            if (state.cartItems.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currencyFormat.format(
                        state.cartItems.fold<double>(
                          0,
                          (sum, item) =>
                              sum + (item.product.price * item.quantity),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (state.cartItems.isNotEmpty)
              Container(
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
                        onPressed: () => _confirmClearOrder(context),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                widget.onProceedToPayment ??
                                () => context.push('/select-payment-method'),
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
                                const Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );

        return Scaffold(body: content);
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
        context.read<HomeBloc>().add(HomeCartCleared());
      }
    }
  }
}
