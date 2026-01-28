import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/product.dart';

void main() {
  group('Product', () {
    const addition = Addition(id: 'a1', name: 'Cheese', price: 500);
    const product = Product(
      id: '1',
      name: 'Test Product',
      price: 1000,
      imageUrl: 'image.png',
      additions: [addition],
    );

    test('supports value equality', () {
      expect(
        product,
        equals(
          const Product(
            id: '1',
            name: 'Test Product',
            price: 1000,
            imageUrl: 'image.png',
            additions: [addition],
          ),
        ),
      );
    });

    test('fromJson creates correct instance', () {
      final json = {
        'id': '1',
        'name': 'Test Product',
        'price': 1000.0,
        'description': '',
        'imageUrl': 'image.png',
        'additions': [
          {'id': 'a1', 'name': 'Cheese', 'price': 500.0},
        ],
      };

      expect(Product.fromJson(json), equals(product));
    });

    test('toJson returns correct map', () {
      final json = product.toJson();
      expect(
        json,
        equals({
          'id': '1',
          'name': 'Test Product',
          'price': 1000.0,
          'description': '',
          'imageUrl': 'image.png',
          'additions': [
            {'id': 'a1', 'name': 'Cheese', 'price': 500.0},
          ],
        }),
      );
    });
  });
}
