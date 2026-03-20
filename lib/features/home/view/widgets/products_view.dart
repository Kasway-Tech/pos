import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/view/widgets/product_card.dart';
import 'package:flutter/material.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({
    super.key,
    required this.items,
    required this.onTap,
    required this.onLongPress,
    this.bottomPadding = 0.0,
  });

  final List<Product> items;
  final ValueChanged<Product> onTap;
  final ValueChanged<Product> onLongPress;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 0.85,
          ),
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + bottomPadding),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final product = items[index];

            return ProductCard(
              product: product,
              onTap: () => onTap(product),
              onLongPress: () => onLongPress(product),
            );
          },
        );
      },
    );
  }
}
