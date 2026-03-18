import 'dart:math';

import 'package:kasway/data/database/app_database.dart';

class OrderRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> createOrder(double totalIdr) async {
    final db = await _db.database;
    await db.insert('orders', {
      'id': _newId(),
      'total_idr': totalIdr,
      'created_at': DateTime.now().millisecondsSinceEpoch,
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

  String _newId() {
    final rng = Random.secure();
    final b = List<int>.generate(16, (_) => rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }
}
