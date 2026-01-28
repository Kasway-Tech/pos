import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';

void main() {
  group('CartItem', () {
    const addition = Addition(id: 'a1', name: 'Cheese', price: 500);
    const product = Product(
      id: '1',
      name: 'Test Product',
      price: 1000,
      imageUrl: 'image.png',
    );

    const cartItem = CartItem(
      product: product,
      quantity: 2,
      selectedAdditions: [addition],
    );

    test('supports value equality', () {
      expect(
        cartItem,
        equals(
          const CartItem(
            product: product,
            quantity: 2,
            selectedAdditions: [addition],
          ),
        ),
      );
    });

    test('calculates totalPrice correctly', () {
      // (Product Price + Additions Price) * Quantity
      // (1000 + 500) * 2 = 3000
      expect(cartItem.totalPrice, equals(3000));
    });

    test('calculates totalPrice correctly without additions', () {
      const itemNoAdditions = CartItem(product: product, quantity: 3);
      // 1000 * 3 = 3000
      expect(itemNoAdditions.totalPrice, equals(3000));
    });

    test('copyWith updates fields correctly', () {
      final updated = cartItem.copyWith(quantity: 5);
      expect(updated.quantity, equals(5));
      expect(updated.product, equals(product));
      expect(updated.selectedAdditions, equals([addition]));
    });
  });
}
