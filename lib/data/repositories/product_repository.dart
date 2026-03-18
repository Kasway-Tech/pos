import 'package:kasway/data/database/app_database.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/product.dart';

class ProductRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<String>> getCategories() async {
    final db = await _db.database;
    final rows = await db.query('categories', orderBy: 'sort_order ASC');
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await _db.database;
    final productRows = await db.query(
      'products',
      where: 'category_name = ?',
      whereArgs: [category],
      orderBy: 'created_at ASC',
    );
    final products = <Product>[];
    for (final row in productRows) {
      final additionRows = await db.query(
        'additions',
        where: 'product_id = ?',
        whereArgs: [row['id']],
      );
      products.add(Product(
        id: row['id'] as String,
        name: row['name'] as String,
        price: row['price'] as double,
        description: row['description'] as String? ?? '',
        additions: additionRows
            .map((a) => Addition(
                  id: a['id'] as String,
                  name: a['name'] as String,
                  price: a['price'] as double,
                ))
            .toList(),
      ));
    }
    return products;
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
      });
      for (final a in p.additions) {
        await txn.insert('additions', {
          'id': a.id,
          'product_id': p.id,
          'name': a.name,
          'price': a.price,
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
    await db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }

  Future<int> countProductsInCategory(String name) async {
    final db = await _db.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM products WHERE category_name = ?',
        [name]);
    return result.first['count'] as int;
  }
}
