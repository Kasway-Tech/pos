import 'package:atomikpos/data/models/product.dart';

class ProductRepository {
  Future<List<Product>> getProductsByCategory(String category) async {
    // Simulating network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    switch (category) {
      case 'Promo':
        return _promoItems;
      case 'Makanan':
        return _foodItems;
      case 'Minuman':
        return _drinkItems;
      case 'Paket':
        return _packageItems;
      case 'Lainnya':
        return _otherItems;
      default:
        return [];
    }
  }

  static const _promoItems = <Product>[
    Product(id: 'p1', name: 'Promo 1', price: 10000),
    Product(id: 'p2', name: 'Promo 2', price: 20000),
    Product(id: 'p3', name: 'Promo 3', price: 30000),
    Product(id: 'p4', name: 'Promo 4', price: 40000),
    Product(id: 'p5', name: 'Promo 5', price: 50000),
    Product(id: 'p6', name: 'Promo 6', price: 60000),
    Product(id: 'p7', name: 'Promo 7', price: 70000),
    Product(id: 'p8', name: 'Promo 8', price: 80000),
    Product(id: 'p9', name: 'Promo 9', price: 90000),
    Product(id: 'p10', name: 'Promo 10', price: 100000),
  ];

  static const _foodItems = <Product>[
    Product(id: 'f1', name: 'Makanan 1', price: 10000),
    Product(id: 'f2', name: 'Makanan 2', price: 20000),
    Product(id: 'f3', name: 'Makanan 3', price: 30000),
    Product(id: 'f4', name: 'Makanan 4', price: 40000),
    Product(id: 'f5', name: 'Makanan 5', price: 50000),
    Product(id: 'f6', name: 'Makanan 6', price: 60000),
    Product(id: 'f7', name: 'Makanan 7', price: 70000),
    Product(id: 'f8', name: 'Makanan 8', price: 80000),
    Product(id: 'f9', name: 'Makanan 9', price: 90000),
    Product(id: 'f10', name: 'Makanan 10', price: 100000),
  ];

  static const _drinkItems = <Product>[
    Product(id: 'd1', name: 'Minuman 1', price: 10000),
    Product(id: 'd2', name: 'Minuman 2', price: 20000),
    Product(id: 'd3', name: 'Minuman 3', price: 30000),
    Product(id: 'd4', name: 'Minuman 4', price: 40000),
    Product(id: 'd5', name: 'Minuman 5', price: 50000),
    Product(id: 'd6', name: 'Minuman 6', price: 60000),
    Product(id: 'd7', name: 'Minuman 7', price: 70000),
    Product(id: 'd8', name: 'Minuman 8', price: 80000),
    Product(id: 'd9', name: 'Minuman 9', price: 90000),
    Product(id: 'd10', name: 'Minuman 10', price: 100000),
  ];

  static const _packageItems = <Product>[
    Product(id: 'pk1', name: 'Paket 1', price: 10000),
    Product(id: 'pk2', name: 'Paket 2', price: 20000),
    Product(id: 'pk3', name: 'Paket 3', price: 30000),
    Product(id: 'pk4', name: 'Paket 4', price: 40000),
    Product(id: 'pk5', name: 'Paket 5', price: 50000),
    Product(id: 'pk6', name: 'Paket 6', price: 60000),
    Product(id: 'pk7', name: 'Paket 7', price: 70000),
    Product(id: 'pk8', name: 'Paket 8', price: 80000),
    Product(id: 'pk9', name: 'Paket 9', price: 90000),
    Product(id: 'pk10', name: 'Paket 10', price: 100000),
  ];

  static const _otherItems = <Product>[
    Product(id: 'o1', name: 'Lainnya 1', price: 10000),
    Product(id: 'o2', name: 'Lainnya 2', price: 20000),
    Product(id: 'o3', name: 'Lainnya 3', price: 30000),
    Product(id: 'o4', name: 'Lainnya 4', price: 40000),
    Product(id: 'o5', name: 'Lainnya 5', price: 50000),
    Product(id: 'o6', name: 'Lainnya 6', price: 60000),
    Product(id: 'o7', name: 'Lainnya 7', price: 70000),
    Product(id: 'o8', name: 'Lainnya 8', price: 80000),
    Product(id: 'o9', name: 'Lainnya 9', price: 90000),
    Product(id: 'o10', name: 'Lainnya 10', price: 100000),
  ];
}
