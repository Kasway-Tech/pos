import 'package:kasway/data/database/app_database.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/product.dart';

class ProductWithCategory {
  final String category;
  final Product product;

  const ProductWithCategory({required this.category, required this.product});
}

class ProductRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<String>> getCategories() async {
    final db = await _db.database;
    final rows = await db.query('categories', orderBy: 'sort_order ASC');
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT p.id, p.name, p.price, p.description, p.kas_price,
             a.id as add_id, a.name as add_name, a.price as add_price,
             a.kas_price as add_kas_price
      FROM products p
      LEFT JOIN additions a ON a.product_id = p.id
      WHERE p.category_name = ?
      ORDER BY p.created_at ASC
    ''', [category]);
    return _groupProductRows(rows);
  }

  /// Groups flat JOIN rows (products LEFT JOIN additions) into [Product] objects,
  /// preserving the row ordering for products and their additions.
  List<Product> _groupProductRows(List<Map<String, Object?>> rows) {
    final productMap = <String, Product>{};
    final productOrder = <String>[];

    for (final row in rows) {
      final productId = row['id'] as String;
      if (!productMap.containsKey(productId)) {
        productMap[productId] = Product(
          id: productId,
          name: row['name'] as String,
          price: row['price'] as double,
          description: row['description'] as String? ?? '',
          kasPrice: row['kas_price'] as double?,
          additions: [],
        );
        productOrder.add(productId);
      }

      final addId = row['add_id'] as String?;
      if (addId != null) {
        final existing = productMap[productId]!;
        productMap[productId] = existing.copyWith(
          additions: [
            ...existing.additions,
            Addition(
              id: addId,
              name: row['add_name'] as String,
              price: row['add_price'] as double,
              kasPrice: row['add_kas_price'] as double?,
            ),
          ],
        );
      }
    }

    return productOrder.map((id) => productMap[id]!).toList();
  }

  Future<void> insertProduct(Product p, String category) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.insert('products', {
        'id': p.id,
        'name': p.name,
        'price': p.price,
        'description': p.description,
        'category_name': category,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'kas_price': p.kasPrice,
      });
      for (final a in p.additions) {
        await txn.insert('additions', {
          'id': a.id,
          'product_id': p.id,
          'name': a.name,
          'price': a.price,
          'kas_price': a.kasPrice,
        });
      }
    });
  }

  Future<void> updateProduct(Product p, String category) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'products',
        {
          'name': p.name,
          'price': p.price,
          'description': p.description,
          'category_name': category,
          'kas_price': p.kasPrice,
        },
        where: 'id = ?',
        whereArgs: [p.id],
      );
      await txn.delete('additions', where: 'product_id = ?', whereArgs: [p.id]);
      for (final a in p.additions) {
        await txn.insert('additions', {
          'id': a.id,
          'product_id': p.id,
          'name': a.name,
          'price': a.price,
          'kas_price': a.kasPrice,
        });
      }
    });
  }

  Future<void> deleteProduct(String productId) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('additions',
          where: 'product_id = ?', whereArgs: [productId]);
      await txn.delete('products', where: 'id = ?', whereArgs: [productId]);
    });
  }

  Future<void> insertCategory(String name, int sortOrder) async {
    final db = await _db.database;
    await db.insert('categories', {'name': name, 'sort_order': sortOrder});
  }

  Future<void> renameCategory(String oldName, String newName) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'products',
        {'category_name': newName},
        where: 'category_name = ?',
        whereArgs: [oldName],
      );
      await txn.update(
        'categories',
        {'name': newName},
        where: 'name = ?',
        whereArgs: [oldName],
      );
    });
  }

  Future<void> deleteCategory(String name) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      // Fetch product ids in this category to delete their additions
      final rows = await txn.query('products',
          columns: ['id'], where: 'category_name = ?', whereArgs: [name]);
      for (final row in rows) {
        await txn.delete('additions',
            where: 'product_id = ?', whereArgs: [row['id']]);
      }
      await txn.delete('products',
          where: 'category_name = ?', whereArgs: [name]);
      await txn.delete('categories', where: 'name = ?', whereArgs: [name]);
    });
  }

  Future<int> countProductsInCategory(String name) async {
    final db = await _db.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM products WHERE category_name = ?',
        [name]);
    return result.first['count'] as int;
  }

  Future<List<ProductWithCategory>> getAllProducts() async {
    final db = await _db.database;
    // Fetch category order in one query, then all products+additions in one JOIN.
    final catRows = await db.query('categories', orderBy: 'sort_order ASC');
    final categoryOrder = {
      for (var i = 0; i < catRows.length; i++)
        catRows[i]['name'] as String: i,
    };

    final rows = await db.rawQuery('''
      SELECT p.id, p.name, p.price, p.description, p.kas_price,
             p.category_name,
             a.id as add_id, a.name as add_name, a.price as add_price,
             a.kas_price as add_kas_price
      FROM products p
      LEFT JOIN additions a ON a.product_id = p.id
      ORDER BY p.category_name, p.created_at ASC
    ''');

    // Group rows into Product objects (preserving per-product addition order).
    final productMap = <String, Product>{};
    final productCategory = <String, String>{};
    final productOrder = <String>[];

    for (final row in rows) {
      final productId = row['id'] as String;
      if (!productMap.containsKey(productId)) {
        productMap[productId] = Product(
          id: productId,
          name: row['name'] as String,
          price: row['price'] as double,
          description: row['description'] as String? ?? '',
          kasPrice: row['kas_price'] as double?,
          additions: [],
        );
        productCategory[productId] = row['category_name'] as String;
        productOrder.add(productId);
      }

      final addId = row['add_id'] as String?;
      if (addId != null) {
        final existing = productMap[productId]!;
        productMap[productId] = existing.copyWith(
          additions: [
            ...existing.additions,
            Addition(
              id: addId,
              name: row['add_name'] as String,
              price: row['add_price'] as double,
              kasPrice: row['add_kas_price'] as double?,
            ),
          ],
        );
      }
    }

    // Sort products by category sort_order, then by their original created_at order.
    productOrder.sort((a, b) {
      final catA = categoryOrder[productCategory[a]] ?? 0;
      final catB = categoryOrder[productCategory[b]] ?? 0;
      return catA.compareTo(catB);
    });

    return productOrder
        .map((id) => ProductWithCategory(
              category: productCategory[id]!,
              product: productMap[id]!,
            ))
        .toList();
  }

  Future<void> importProducts(List<Map<String, dynamic>> products) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final sortResult = await txn
          .rawQuery('SELECT MAX(sort_order) as max_sort FROM categories');
      int nextSort = ((sortResult.first['max_sort'] as int?) ?? -1) + 1;

      final catRows = await txn.query('categories');
      final existingCats =
          catRows.map((r) => r['name'] as String).toSet();

      for (final p in products) {
        final category = p['category'] as String;
        if (!existingCats.contains(category)) {
          await txn.insert(
              'categories', {'name': category, 'sort_order': nextSort++});
          existingCats.add(category);
        }

        final productId = p['id'] as String;
        final existing = await txn
            .query('products', where: 'id = ?', whereArgs: [productId]);
        final now = DateTime.now().millisecondsSinceEpoch;

        if (existing.isEmpty) {
          await txn.insert('products', {
            'id': productId,
            'name': p['name'],
            'price': p['price'],
            'description': p['description'] ?? '',
            'category_name': category,
            'created_at': now,
          });
        } else {
          await txn.update(
            'products',
            {
              'name': p['name'],
              'price': p['price'],
              'description': p['description'] ?? '',
              'category_name': category,
            },
            where: 'id = ?',
            whereArgs: [productId],
          );
        }

        await txn.delete(
            'additions', where: 'product_id = ?', whereArgs: [productId]);
        final additions =
            p['additions'] as List<Map<String, dynamic>>;
        for (int i = 0; i < additions.length; i++) {
          final a = additions[i];
          await txn.insert('additions', {
            'id': 'add_${productId}_$i',
            'product_id': productId,
            'name': a['name'],
            'price': a['price'],
          });
        }
      }
    });
  }
}
