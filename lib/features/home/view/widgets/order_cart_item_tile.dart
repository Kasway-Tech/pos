import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/home/view/widgets/numeric_input_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCartItemTile extends StatefulWidget {
  const OrderCartItemTile({super.key, required this.cartItem});

  final CartItem cartItem;

  @override
  State<OrderCartItemTile> createState() => _OrderCartItemTileState();
}

class _OrderCartItemTileState extends State<OrderCartItemTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  double get _additionsTotal => widget.cartItem.selectedAdditions.fold(
    0.0,
    (sum, addition) => sum + addition.price,
  );

  double get _itemTotal =>
      (widget.cartItem.product.price + _additionsTotal) *
      widget.cartItem.quantity;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final product = widget.cartItem.product;
    final hasAdditions = widget.cartItem.selectedAdditions.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 4.0 : 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocSelector<HomeBloc, HomeState, int>(
            selector: (state) {
              try {
                final item = state.cartItems.firstWhere(
                  (item) =>
                      item.product.id == product.id &&
                      _compareAdditions(
                        item.selectedAdditions,
                        widget.cartItem.selectedAdditions,
                      ),
                );
                return item.quantity.toInt();
              } catch (_) {
                return widget.cartItem.quantity.toInt();
              }
            },
            builder: (context, quantity) {
              return NumericInputGroup(
                value: quantity,
                onChanged: (newQty) {
                  context.read<HomeBloc>().add(
                    HomeCartQuantityUpdated(
                      product,
                      newQty.toDouble(),
                      selectedAdditions: widget.cartItem.selectedAdditions,
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: hasAdditions
                  ? () => setState(() => _isExpanded = !_isExpanded)
                  : null,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                product.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PriceText(
                        _itemTotal,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (hasAdditions)
                    AnimatedCrossFade(
                      firstChild: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.cartItem.selectedAdditions.length} addition${widget.cartItem.selectedAdditions.length > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                          _additionsTotal > 0
                              ? PriceText(
                                  _additionsTotal,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                )
                              : Text(
                                  'FREE',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                ),
                        ],
                      ),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          ...widget.cartItem.selectedAdditions.map(
                            (addition) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    addition.name,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                  ),
                                  addition.price > 0
                                      ? PriceText(
                                          addition.price,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                          ),
                                        )
                                      : Text(
                                          'FREE',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                      sizeCurve: Curves.easeInOut,
                    )
                  else
                    Text(
                      'No additions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _compareAdditions(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.id).toSet();
    final bIds = b.map((e) => e.id).toSet();
    return aIds.containsAll(bIds) && bIds.containsAll(aIds);
  }
}
