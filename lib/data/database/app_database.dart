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
    return openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE products ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0');
      // Backfill existing rows with rowid so their relative order is preserved.
      await db.execute('UPDATE products SET created_at = rowid');
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

    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    await db.transaction((txn) async {
      for (final cat in _seedCategories) {
        await txn.insert('categories', cat);
      }
      for (final p in _seedProducts) {
        await txn.insert('products', p);
      }
      for (final a in _seedAdditions) {
        await txn.insert('additions', a);
      }
    });
  }

  static const _seedCategories = <Map<String, dynamic>>[
    {'name': 'Promo', 'sort_order': 0},
    {'name': 'Makanan', 'sort_order': 1},
    {'name': 'Minuman', 'sort_order': 2},
    {'name': 'Paket', 'sort_order': 3},
    {'name': 'Lainnya', 'sort_order': 4},
  ];

  static const _seedProducts = <Map<String, dynamic>>[
    // Promo
    {'id': 'p1', 'name': 'Promo 1', 'price': 10000.0, 'description': '', 'category_name': 'Promo'},
    {'id': 'p2', 'name': 'Promo 2', 'price': 20000.0, 'description': '', 'category_name': 'Promo'},
    {'id': 'p3', 'name': 'Promo 3', 'price': 30000.0, 'description': '', 'category_name': 'Promo'},
    {'id': 'p4', 'name': 'Promo 4', 'price': 40000.0, 'description': '', 'category_name': 'Promo'},
    {'id': 'p5', 'name': 'Promo 5', 'price': 50000.0, 'description': '', 'category_name': 'Promo'},
    {'id': 'p6', 'name': 'Promo 6', 'price': 60000.0, 'description': '', 'category_name': 'Promo'},
    {'id': 'p7', 'name': 'Promo 7', 'price': 70000.0, 'description': '', 'category_name': 'Promo'},
    {'id': 'p8', 'name': 'Promo 8', 'price': 80000.0, 'description': '', 'category_name': 'Promo'},
    {'id': 'p9', 'name': 'Promo 9', 'price': 90000.0, 'description': '', 'category_name': 'Promo'},
    {'id': 'p10', 'name': 'Promo 10', 'price': 100000.0, 'description': '', 'category_name': 'Promo'},
    // Makanan
    {'id': 'f1', 'name': 'Nasi Goreng', 'price': 25000.0, 'description': '', 'category_name': 'Makanan'},
    {'id': 'f2', 'name': 'Mie Goreng', 'price': 22000.0, 'description': '', 'category_name': 'Makanan'},
    {'id': 'f3', 'name': 'Burger Deluxe', 'price': 35000.0, 'description': '', 'category_name': 'Makanan'},
    {'id': 'f4', 'name': 'Pizza Slice', 'price': 30000.0, 'description': '', 'category_name': 'Makanan'},
    {'id': 'f5', 'name': 'Makanan 5', 'price': 50000.0, 'description': '', 'category_name': 'Makanan'},
    {'id': 'f6', 'name': 'Makanan 6', 'price': 60000.0, 'description': '', 'category_name': 'Makanan'},
    {'id': 'f7', 'name': 'Makanan 7', 'price': 70000.0, 'description': '', 'category_name': 'Makanan'},
    {'id': 'f8', 'name': 'Makanan 8', 'price': 80000.0, 'description': '', 'category_name': 'Makanan'},
    {'id': 'f9', 'name': 'Makanan 9', 'price': 90000.0, 'description': '', 'category_name': 'Makanan'},
    {'id': 'f10', 'name': 'Makanan 10', 'price': 100000.0, 'description': '', 'category_name': 'Makanan'},
    // Minuman
    {'id': 'd1', 'name': 'Espresso', 'price': 18000.0, 'description': '', 'category_name': 'Minuman'},
    {'id': 'd2', 'name': 'Cappuccino', 'price': 25000.0, 'description': '', 'category_name': 'Minuman'},
    {'id': 'd3', 'name': 'Latte', 'price': 28000.0, 'description': '', 'category_name': 'Minuman'},
    {'id': 'd4', 'name': 'Americano', 'price': 22000.0, 'description': '', 'category_name': 'Minuman'},
    {'id': 'd5', 'name': 'Matcha Latte', 'price': 30000.0, 'description': '', 'category_name': 'Minuman'},
    {'id': 'd6', 'name': 'Minuman 6', 'price': 60000.0, 'description': '', 'category_name': 'Minuman'},
    {'id': 'd7', 'name': 'Minuman 7', 'price': 70000.0, 'description': '', 'category_name': 'Minuman'},
    {'id': 'd8', 'name': 'Minuman 8', 'price': 80000.0, 'description': '', 'category_name': 'Minuman'},
    {'id': 'd9', 'name': 'Minuman 9', 'price': 90000.0, 'description': '', 'category_name': 'Minuman'},
    {'id': 'd10', 'name': 'Minuman 10', 'price': 100000.0, 'description': '', 'category_name': 'Minuman'},
    // Paket
    {'id': 'pk1', 'name': 'Paket Hemat 1', 'price': 45000.0, 'description': '', 'category_name': 'Paket'},
    {'id': 'pk2', 'name': 'Paket Hemat 2', 'price': 55000.0, 'description': '', 'category_name': 'Paket'},
    {'id': 'pk3', 'name': 'Paket 3', 'price': 30000.0, 'description': '', 'category_name': 'Paket'},
    {'id': 'pk4', 'name': 'Paket 4', 'price': 40000.0, 'description': '', 'category_name': 'Paket'},
    {'id': 'pk5', 'name': 'Paket 5', 'price': 50000.0, 'description': '', 'category_name': 'Paket'},
    {'id': 'pk6', 'name': 'Paket 6', 'price': 60000.0, 'description': '', 'category_name': 'Paket'},
    {'id': 'pk7', 'name': 'Paket 7', 'price': 70000.0, 'description': '', 'category_name': 'Paket'},
    {'id': 'pk8', 'name': 'Paket 8', 'price': 80000.0, 'description': '', 'category_name': 'Paket'},
    {'id': 'pk9', 'name': 'Paket 9', 'price': 90000.0, 'description': '', 'category_name': 'Paket'},
    {'id': 'pk10', 'name': 'Paket 10', 'price': 100000.0, 'description': '', 'category_name': 'Paket'},
    // Lainnya
    {'id': 'o1', 'name': 'Lainnya 1', 'price': 10000.0, 'description': '', 'category_name': 'Lainnya'},
    {'id': 'o2', 'name': 'Lainnya 2', 'price': 20000.0, 'description': '', 'category_name': 'Lainnya'},
    {'id': 'o3', 'name': 'Lainnya 3', 'price': 30000.0, 'description': '', 'category_name': 'Lainnya'},
    {'id': 'o4', 'name': 'Lainnya 4', 'price': 40000.0, 'description': '', 'category_name': 'Lainnya'},
    {'id': 'o5', 'name': 'Lainnya 5', 'price': 50000.0, 'description': '', 'category_name': 'Lainnya'},
    {'id': 'o6', 'name': 'Lainnya 6', 'price': 60000.0, 'description': '', 'category_name': 'Lainnya'},
    {'id': 'o7', 'name': 'Lainnya 7', 'price': 70000.0, 'description': '', 'category_name': 'Lainnya'},
    {'id': 'o8', 'name': 'Lainnya 8', 'price': 80000.0, 'description': '', 'category_name': 'Lainnya'},
    {'id': 'o9', 'name': 'Lainnya 9', 'price': 90000.0, 'description': '', 'category_name': 'Lainnya'},
    {'id': 'o10', 'name': 'Lainnya 10', 'price': 100000.0, 'description': '', 'category_name': 'Lainnya'},
  ];

  static const _seedAdditions = <Map<String, dynamic>>[
    // Food additions for f1–f4
    {'id': 'add_extra_cheese__f1', 'product_id': 'f1', 'name': 'Extra Cheese', 'price': 5000.0},
    {'id': 'add_extra_sauce__f1', 'product_id': 'f1', 'name': 'Extra Sauce', 'price': 3000.0},
    {'id': 'add_no_onion__f1', 'product_id': 'f1', 'name': 'No Onion', 'price': 0.0},
    {'id': 'add_extra_spicy__f1', 'product_id': 'f1', 'name': 'Extra Spicy', 'price': 0.0},

    {'id': 'add_extra_cheese__f2', 'product_id': 'f2', 'name': 'Extra Cheese', 'price': 5000.0},
    {'id': 'add_extra_sauce__f2', 'product_id': 'f2', 'name': 'Extra Sauce', 'price': 3000.0},
    {'id': 'add_no_onion__f2', 'product_id': 'f2', 'name': 'No Onion', 'price': 0.0},
    {'id': 'add_extra_spicy__f2', 'product_id': 'f2', 'name': 'Extra Spicy', 'price': 0.0},

    {'id': 'add_extra_cheese__f3', 'product_id': 'f3', 'name': 'Extra Cheese', 'price': 5000.0},
    {'id': 'add_extra_sauce__f3', 'product_id': 'f3', 'name': 'Extra Sauce', 'price': 3000.0},
    {'id': 'add_no_onion__f3', 'product_id': 'f3', 'name': 'No Onion', 'price': 0.0},
    {'id': 'add_extra_spicy__f3', 'product_id': 'f3', 'name': 'Extra Spicy', 'price': 0.0},

    {'id': 'add_extra_cheese__f4', 'product_id': 'f4', 'name': 'Extra Cheese', 'price': 5000.0},
    {'id': 'add_extra_sauce__f4', 'product_id': 'f4', 'name': 'Extra Sauce', 'price': 3000.0},
    {'id': 'add_no_onion__f4', 'product_id': 'f4', 'name': 'No Onion', 'price': 0.0},
    {'id': 'add_extra_spicy__f4', 'product_id': 'f4', 'name': 'Extra Spicy', 'price': 0.0},

    // Drink additions for d1–d5
    {'id': 'add_extra_shot__d1', 'product_id': 'd1', 'name': 'Extra Shot', 'price': 5000.0},
    {'id': 'add_less_sugar__d1', 'product_id': 'd1', 'name': 'Less Sugar', 'price': 0.0},
    {'id': 'add_oat_milk__d1', 'product_id': 'd1', 'name': 'Oat Milk', 'price': 8000.0},
    {'id': 'add_whipped_cream__d1', 'product_id': 'd1', 'name': 'Whipped Cream', 'price': 5000.0},

    {'id': 'add_extra_shot__d2', 'product_id': 'd2', 'name': 'Extra Shot', 'price': 5000.0},
    {'id': 'add_less_sugar__d2', 'product_id': 'd2', 'name': 'Less Sugar', 'price': 0.0},
    {'id': 'add_oat_milk__d2', 'product_id': 'd2', 'name': 'Oat Milk', 'price': 8000.0},
    {'id': 'add_whipped_cream__d2', 'product_id': 'd2', 'name': 'Whipped Cream', 'price': 5000.0},

    {'id': 'add_extra_shot__d3', 'product_id': 'd3', 'name': 'Extra Shot', 'price': 5000.0},
    {'id': 'add_less_sugar__d3', 'product_id': 'd3', 'name': 'Less Sugar', 'price': 0.0},
    {'id': 'add_oat_milk__d3', 'product_id': 'd3', 'name': 'Oat Milk', 'price': 8000.0},
    {'id': 'add_whipped_cream__d3', 'product_id': 'd3', 'name': 'Whipped Cream', 'price': 5000.0},

    {'id': 'add_extra_shot__d4', 'product_id': 'd4', 'name': 'Extra Shot', 'price': 5000.0},
    {'id': 'add_less_sugar__d4', 'product_id': 'd4', 'name': 'Less Sugar', 'price': 0.0},
    {'id': 'add_oat_milk__d4', 'product_id': 'd4', 'name': 'Oat Milk', 'price': 8000.0},
    {'id': 'add_whipped_cream__d4', 'product_id': 'd4', 'name': 'Whipped Cream', 'price': 5000.0},

    {'id': 'add_extra_shot__d5', 'product_id': 'd5', 'name': 'Extra Shot', 'price': 5000.0},
    {'id': 'add_less_sugar__d5', 'product_id': 'd5', 'name': 'Less Sugar', 'price': 0.0},
    {'id': 'add_oat_milk__d5', 'product_id': 'd5', 'name': 'Oat Milk', 'price': 8000.0},
    {'id': 'add_whipped_cream__d5', 'product_id': 'd5', 'name': 'Whipped Cream', 'price': 5000.0},

    // Paket additions for pk1 and pk2
    {'id': 'add_upsize_drink__pk1', 'product_id': 'pk1', 'name': 'Upsize Drink', 'price': 5000.0},
    {'id': 'add_extra_fries__pk1', 'product_id': 'pk1', 'name': 'Extra Fries', 'price': 8000.0},

    {'id': 'add_upsize_drink__pk2', 'product_id': 'pk2', 'name': 'Upsize Drink', 'price': 5000.0},
    {'id': 'add_extra_fries__pk2', 'product_id': 'pk2', 'name': 'Extra Fries', 'price': 8000.0},
  ];
}
