import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'kasway.db');
    return openDatabase(path, version: 8, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE products ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0');
      // Backfill existing rows with rowid so their relative order is preserved.
      await db.execute('UPDATE products SET created_at = rowid');
    }
    if (oldVersion < 3) {
      await db.delete('additions');
      await db.delete('products');
      await db.delete('categories');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS orders (
          id         TEXT PRIMARY KEY,
          total_idr  REAL NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS withdrawals (
          tx_id       TEXT PRIMARY KEY,
          to_address  TEXT NOT NULL,
          amount_kas  REAL NOT NULL,
          amount_idr  REAL NOT NULL,
          created_at  INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute(
          'ALTER TABLE withdrawals ADD COLUMN kas_idr_rate REAL NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE withdrawals ADD COLUMN ref_fiat_code TEXT NOT NULL DEFAULT \'IDR\'');
      await db.execute(
          'ALTER TABLE withdrawals ADD COLUMN ref_fiat_amount REAL NOT NULL DEFAULT 0');
    }
    if (oldVersion < 7) {
      await db.execute(
          'ALTER TABLE orders ADD COLUMN kas_amount REAL NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE orders ADD COLUMN kas_idr_rate REAL NOT NULL DEFAULT 0');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS order_items (
          id           TEXT PRIMARY KEY,
          order_id     TEXT NOT NULL,
          product_name TEXT NOT NULL,
          unit_price   REAL NOT NULL,
          quantity     INTEGER NOT NULL,
          additions    TEXT NOT NULL DEFAULT '[]'
        )
      ''');
    }
    if (oldVersion < 8) {
      await db.execute(
          "ALTER TABLE orders ADD COLUMN tx_id TEXT NOT NULL DEFAULT ''");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        name       TEXT PRIMARY KEY,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id            TEXT PRIMARY KEY,
        name          TEXT NOT NULL,
        price         REAL NOT NULL,
        description   TEXT NOT NULL DEFAULT '',
        category_name TEXT NOT NULL,
        created_at    INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE additions (
        id         TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        name       TEXT NOT NULL,
        price      REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id           TEXT PRIMARY KEY,
        total_idr    REAL NOT NULL,
        kas_amount   REAL NOT NULL DEFAULT 0,
        kas_idr_rate REAL NOT NULL DEFAULT 0,
        tx_id        TEXT NOT NULL DEFAULT '',
        created_at   INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id           TEXT PRIMARY KEY,
        order_id     TEXT NOT NULL,
        product_name TEXT NOT NULL,
        unit_price   REAL NOT NULL,
        quantity     INTEGER NOT NULL,
        additions    TEXT NOT NULL DEFAULT '[]'
      )
    ''');

    await db.execute('''
      CREATE TABLE withdrawals (
        tx_id           TEXT PRIMARY KEY,
        to_address      TEXT NOT NULL,
        amount_kas      REAL NOT NULL,
        amount_idr      REAL NOT NULL,
        kas_idr_rate    REAL NOT NULL DEFAULT 0,
        ref_fiat_code   TEXT NOT NULL DEFAULT 'IDR',
        ref_fiat_amount REAL NOT NULL DEFAULT 0,
        created_at      INTEGER NOT NULL
      )
    ''');
  }
}
