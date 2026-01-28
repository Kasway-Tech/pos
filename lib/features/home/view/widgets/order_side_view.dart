import 'package:atomikpos/features/home/bloc/home_bloc.dart';
import 'package:atomikpos/features/home/bloc/home_event.dart';
import 'package:atomikpos/features/home/bloc/home_state.dart';
import 'package:atomikpos/features/home/view/widgets/order_cart_item_tile.dart';
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.cartItems.length != current.cartItems.length,
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
                toolbarHeight: isTablet
                    ? kToolbarHeight + 8.0
                    : kToolbarHeight + 16.0,
                title: const Text('Order List'),
                centerTitle: false,
                scrolledUnderElevation: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                actions: [
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
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
                child: ListView.builder(
                  key: const PageStorageKey('order_list'),
                  controller: _scrollController,
                  padding: EdgeInsets.all(isTablet ? 12.0 : 16.0),
                  itemCount: state.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = state.cartItems[index];
                    return OrderCartItemTile(cartItem: item);
                  },
                ),
              ),
            ),
            if (state.cartItems.isNotEmpty || screenWidth >= 800)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16.0 : 24.0,
                  vertical: isTablet ? 12.0 : 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Grand Total',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocSelector<HomeBloc, HomeState, double>(
                      selector: (state) =>
                          state.cartItems.fold<double>(0, (sum, item) {
                            final additionsTotal = item.selectedAdditions
                                .fold<double>(
                                  0,
                                  (addSum, addition) => addSum + addition.price,
                                );
                            return sum +
                                ((item.product.price + additionsTotal) *
                                    item.quantity);
                          }),
                      builder: (context, grandTotal) {
                        return Text(
                          currencyFormat.format(grandTotal),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (state.cartItems.isNotEmpty || screenWidth >= 800)
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
                  height: isTablet
                      ? kToolbarHeight + 8.0
                      : kToolbarHeight + 16.0,
                  child: Row(
                    children: [
                      if (!widget.showAppBar)
                        IconButton(
                          onPressed: () => _confirmClearOrder(context),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          icon: SizedBox(
                            width: isTablet
                                ? kToolbarHeight + 8.0
                                : kToolbarHeight + 16.0,
                            height: double.infinity,
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      if (!widget.showAppBar)
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
                            onPressed: state.cartItems.isEmpty
                                ? null
                                : widget.onProceedToPayment ??
                                      () => context.push(
                                        '/select-payment-method',
                                      ),
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
                                Flexible(
                                  child: Text(
                                    'Proceed to Payment',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
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
