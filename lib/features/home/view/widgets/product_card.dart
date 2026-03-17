import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onLongPress,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _longPressHandled = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    final padding = isTablet ? 12.0 : 16.0;

    return Listener(
      onPointerDown: (_) => _longPressHandled = false,
      child: Bounce(
        onTap: () {
          if (!_longPressHandled) {
            widget.onTap();
          }
        },
        onLongPress: (_) {
          _longPressHandled = true;
          widget.onLongPress();
        },
        tapDelay: const Duration(milliseconds: 50),
        duration: const Duration(milliseconds: 75),
        scaleFactor: 0.96,
        child: BlocSelector<HomeBloc, HomeState, bool>(
          selector: (state) => state.cartItems.any(
            (item) => item.product.id == widget.product.id && item.quantity > 0,
          ),
          builder: (context, active) {
            final hasAdditions = widget.product.additions.isNotEmpty;
            return Stack(
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  color: active ? Theme.of(context).colorScheme.primary : null,
                  child: Container(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        BlocSelector<HomeBloc, HomeState, double>(
                          selector: (state) {
                            try {
                              return state.cartItems
                                  .firstWhere(
                                    (item) =>
                                        item.product.id == widget.product.id,
                                  )
                                  .quantity;
                            } catch (_) {
                              return 0;
                            }
                          },
                          builder: (context, quantity) {
                            return Opacity(
                              opacity: active ? 1 : 0.1,
                              child: Text(
                                quantity.toStringAsFixed(0),
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: active
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimary
                                          : null,
                                    ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.product.name,
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: active
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimary
                                          : null,
                                    ),
                              ),
                              PriceText(
                                widget.product.price,
                                style: TextStyle(
                                  color: active
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasAdditions)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                      child: Icon(
                        Icons.tune,
                        size: 14,
                        color: active
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
