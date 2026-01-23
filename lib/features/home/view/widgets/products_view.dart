import 'package:atomikpos/data/models/cart_item.dart';
import 'package:atomikpos/data/models/product.dart';
import 'package:atomikpos/features/home/view/widgets/product_card.dart';
import 'package:flutter/material.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({
    super.key,
    required this.items,
    required this.cartItems,
    required this.onTap,
    required this.onLongPress,
  });

  final List<Product> items;
  final List<CartItem> cartItems;
  final ValueChanged<Product> onTap;
  final ValueChanged<Product> onLongPress;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];
        final cartItem = cartItems.firstWhere(
          (item) => item.product.id == product.id,
          orElse: () => CartItem(product: product, quantity: 0),
        );

        return ProductCard(
          quantity: cartItem.quantity,
          product: product,
          onTap: () => onTap(product),
          onLongPress: () => onLongPress(product),
        );
      },
    );
  }
}
