import 'package:kasway/data/database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class DonationRecord {
  const DonationRecord({
    required this.txId,
    required this.amountKas,
    required this.isAuto,
    required this.createdAt,
  });

  final String txId;
  final double amountKas;
  final bool isAuto;
  final DateTime createdAt;
}

class DonationRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> recordDonation({
    required String txId,
    required double amountKas,
    required bool isAuto,
  }) async {
    final db = await _db.database;
    await db.insert(
      'donations',
      {
        'tx_id': txId,
        'amount_kas': amountKas,
        'is_auto': isAuto ? 1 : 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<DonationRecord>> getDonations() async {
    final db = await _db.database;
    final rows = await db.query('donations', orderBy: 'created_at DESC');
    return rows
        .map((row) => DonationRecord(
              txId: row['tx_id'] as String,
              amountKas: (row['amount_kas'] as num).toDouble(),
              isAuto: (row['is_auto'] as int) == 1,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                  row['created_at'] as int),
            ))
        .toList();
  }
}
