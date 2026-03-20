import 'dart:convert';
import 'dart:math';

import 'package:kasway/data/database/app_database.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/order.dart';
import 'package:kasway/data/models/order_item.dart';

class OrderRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> createOrder({
    required double totalIdr,
    required double kasAmount,
    required double kasIdrRate,
    required String txId,
    required List<CartItem> cartItems,
  }) async {
    final db = await _db.database;
    final orderId = _newId();
    await db.transaction((txn) async {
      await txn.insert('orders', {
        'id': orderId,
        'total_idr': totalIdr,
        'kas_amount': kasAmount,
        'kas_idr_rate': kasIdrRate,
        'tx_id': txId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      for (final item in cartItems) {
        final addJson = jsonEncode(item.selectedAdditions
            .map((a) => {'name': a.name, 'price': a.price})
            .toList());
        await txn.insert('order_items', {
          'id': _newId(),
          'order_id': orderId,
          'product_name': item.product.name,
          'unit_price': item.product.price,
          'quantity': item.quantity.toInt(),
          'additions': addJson,
        });
      }
    });
  }

  Future<double> getTodayRevenue() async {
    final db = await _db.database;
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total_idr), 0) as revenue FROM orders WHERE created_at >= ?',
      [midnight.millisecondsSinceEpoch],
    );
    return (result.first['revenue'] as num).toDouble();
  }

  Future<double> getTotalRevenue() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total_idr), 0) as revenue FROM orders',
    );
    return (result.first['revenue'] as num).toDouble();
  }

  Future<List<Order>> getOrders() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT o.id, o.total_idr, o.created_at, o.kas_amount, o.kas_idr_rate,
             o.tx_id,
             oi.id as item_id, oi.product_name, oi.unit_price,
             oi.quantity as item_quantity, oi.additions
      FROM orders o
      LEFT JOIN order_items oi ON oi.order_id = o.id
      ORDER BY o.created_at DESC
    ''');

    final Map<String, Order> ordersById = {};
    final Map<String, List<OrderItem>> itemsById = {};

    for (final row in rows) {
      final orderId = row['id'] as String;

      if (!ordersById.containsKey(orderId)) {
        ordersById[orderId] = Order(
          id: orderId,
          totalIdr: (row['total_idr'] as num).toDouble(),
          kasAmount: (row['kas_amount'] as num? ?? 0).toDouble(),
          kasIdrRate: (row['kas_idr_rate'] as num? ?? 0).toDouble(),
          txId: row['tx_id'] as String? ?? '',
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            row['created_at'] as int,
          ),
        );
        itemsById[orderId] = [];
      }

      final itemId = row['item_id'] as String?;
      if (itemId != null) {
        final additionsRaw = row['additions'] as String? ?? '[]';
        final additionsList = (jsonDecode(additionsRaw) as List<dynamic>)
            .map((a) => OrderItemAddition(
                  name: a['name'] as String,
                  price: (a['price'] as num).toDouble(),
                ))
            .toList();

        itemsById[orderId]!.add(OrderItem(
          id: itemId,
          productName: row['product_name'] as String,
          unitPrice: (row['unit_price'] as num).toDouble(),
          quantity: row['item_quantity'] as int,
          additions: additionsList,
        ));
      }
    }

    return ordersById.values.map((order) {
      return order.copyWith(items: itemsById[order.id] ?? []);
    }).toList();
  }

  String _newId() {
    final rng = Random.secure();
    final b = List<int>.generate(16, (_) => rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }
}
