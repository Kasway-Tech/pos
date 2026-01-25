import 'package:atomikpos/data/models/product.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.quantity = 0,
    required this.onTap,
    required this.onLongPress,
  });

  final double quantity;
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _longPressHandled = false;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'IDR ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final active = widget.quantity > 0;

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
        tilt: false,
        tapDelay: const Duration(milliseconds: 50),
        duration: const Duration(milliseconds: 100),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          color: active ? Theme.of(context).colorScheme.primary : null,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Opacity(
                  opacity: active ? 1 : 0.1,
                  child: Text(
                    widget.quantity.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: active
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                  ),
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: active
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(widget.product.price),
                        textAlign: TextAlign.right,
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
      ),
    );
  }
}
