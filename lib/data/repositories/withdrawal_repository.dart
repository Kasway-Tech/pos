import 'package:kasway/data/database/app_database.dart';
import 'package:kasway/data/models/withdrawal.dart';
import 'package:sqflite/sqflite.dart';

class WithdrawalRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> recordWithdrawal({
    required String txId,
    required String toAddress,
    required double amountKas,
    required double amountIdr,
    required double kasIdrRate,
    required DateTime createdAt,
  }) async {
    final db = await _db.database;
    await db.insert(
      'withdrawals',
      {
        'tx_id': txId,
        'to_address': toAddress,
        'amount_kas': amountKas,
        'amount_idr': amountIdr,
        'kas_idr_rate': kasIdrRate,
        'created_at': createdAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Withdrawal>> getWithdrawals() async {
    final db = await _db.database;
    final rows = await db.query(
      'withdrawals',
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<double> getTotalWithdrawn() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount_idr), 0) as total FROM withdrawals',
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<List<Withdrawal>> getAllForExport() async => getWithdrawals();

  Withdrawal _fromRow(Map<String, dynamic> row) {
    return Withdrawal(
      txId: row['tx_id'] as String,
      toAddress: row['to_address'] as String,
      amountKas: (row['amount_kas'] as num).toDouble(),
      amountIdr: (row['amount_idr'] as num).toDouble(),
      kasIdrRate: (row['kas_idr_rate'] as num? ?? 0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
    );
  }
}
