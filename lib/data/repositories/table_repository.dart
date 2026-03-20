import 'dart:math';

import 'package:kasway/data/database/app_database.dart';
import 'package:kasway/data/models/table_item.dart';

class TableRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<TableItem>> getTables() async {
    final db = await _db.database;
    final rows = await db.query('table_items', orderBy: 'rowid ASC');
    return rows.map(_rowToItem).toList();
  }

  /// Full-replace: delete all rows then re-insert in a single transaction.
  Future<void> saveLayout(List<TableItem> tables) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('table_items');
      for (final t in tables) {
        await txn.insert('table_items', _itemToRow(t));
      }
    });
  }

  Future<void> setOccupied(String id, bool occupied) async {
    final db = await _db.database;
    await db.update(
      'table_items',
      {'is_occupied': occupied ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearOccupied() async {
    final db = await _db.database;
    await db.update('table_items', {'is_occupied': 0});
  }

  TableItem _rowToItem(Map<String, Object?> row) => TableItem(
        id: row['id'] as String,
        label: row['label'] as String,
        seats: row['seats'] as int,
        x: (row['x'] as num).toDouble(),
        y: (row['y'] as num).toDouble(),
        rotation: (row['rotation'] as num).toDouble(),
        isOccupied: (row['is_occupied'] as int) == 1,
      );

  Map<String, Object?> _itemToRow(TableItem t) => {
        'id': t.id,
        'label': t.label,
        'seats': t.seats,
        'x': t.x,
        'y': t.y,
        'rotation': t.rotation,
        'is_occupied': t.isOccupied ? 1 : 0,
      };

  String newId() {
    final rng = Random.secure();
    final b = List<int>.generate(16, (_) => rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }
}
