import 'package:flutter/material.dart';
import 'package:kasway/app/widgets/price_text.dart';

/// A row displaying a single line item (product + additions) with its price.
///
/// Used in both the Kaspa payment QR page and order history cards.
class LineItemRow extends StatelessWidget {
  const LineItemRow({
    super.key,
    required this.productName,
    required this.quantity,
    required this.lineTotal,
    required this.additions,
  });

  final String productName;
  final num quantity;

  /// Total price for this line (IDR), including additions × quantity.
  final double lineTotal;

  /// Each addition: name and per-unit price (0 = free).
  final List<({String name, double price})> additions;

  @override
  Widget build(BuildContext context) {
    final outlineStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.outline);

    final qtyStr =
        quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: product name + additions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$productName × $qtyStr',
                    style: Theme.of(context).textTheme.bodyMedium),
                if (additions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text('No additions', style: outlineStyle),
                  )
                else
                  ...additions.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(a.name, style: outlineStyle),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right: line total + per-addition prices
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PriceText(lineTotal,
                  style: Theme.of(context).textTheme.bodyMedium),
              ...additions.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: a.price > 0
                      ? PriceText(a.price, style: outlineStyle)
                      : Text('FREE', style: outlineStyle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
