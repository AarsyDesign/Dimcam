import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../dummy/dummy_data.dart';
import '../models/material_cost.dart';
import '../models/product.dart';
import '../models/stock_item.dart';
import '../models/transaction.dart';

/// 🗄️ Helper SQLite untuk Dimsumia Manager.
/// Menangani inisialisasi, skema, seeding dummy, dan CRUD dasar.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'dimsumia.db';
  static const int _dbVersion = 1;

  Database? _db;
  bool _seeded = false;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final String dbPath = await getDatabasesPath();
    final String path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final Batch batch = db.batch();

    batch.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL DEFAULT '🥟',
        category TEXT NOT NULL DEFAULT 'Dimsum',
        selling_price INTEGER NOT NULL,
        hpp INTEGER NOT NULL,
        unit TEXT NOT NULL DEFAULT 'pcs',
        description TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        total_price INTEGER NOT NULL,
        date_time INTEGER NOT NULL,
        note TEXT,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    batch.execute('''
      CREATE TABLE stocks (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        unit TEXT NOT NULL DEFAULT 'pcs',
        quantity REAL NOT NULL,
        min_quantity REAL NOT NULL,
        emoji TEXT,
        category TEXT NOT NULL DEFAULT 'Bahan'
      )
    ''');

    batch.execute('''
      CREATE TABLE materials (
        id INTEGER PRIMARY KEY,
        product_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        cost INTEGER NOT NULL,
        emoji TEXT,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await batch.commit();
    await _seed(db);
  }

  /// Seed data dummy pada database baru.
  Future<void> _seed(Database db) async {
    if (_seeded) return;
    final Batch batch = db.batch();

    for (final Product prod in DummyData.products) {
      batch.insert('products', prod.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final StockItem s in DummyData.stocks) {
      batch.insert('stocks', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final MaterialCost m in DummyData.materials) {
      batch.insert('materials', m.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    // Transaksi: tanpa id (AUTOINCREMENT).
    for (final Transaction t in DummyData.transactions) {
      batch.insert('transactions', {
        'product_id': t.productId,
        'quantity': t.quantity,
        'total_price': t.totalPrice,
        'date_time': t.dateTime.millisecondsSinceEpoch,
        'note': t.note,
      });
    }

    await batch.commit();
    _seeded = true;
  }

  // ----------------- PRODUCTS -----------------
  Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'id ASC');
    return maps.map(Product.fromMap).toList();
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);
    return maps.isEmpty ? null : Product.fromMap(maps.first);
  }

  Future<int> upsertProduct(Product product) async {
    final db = await database;
    return db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ----------------- TRANSACTIONS -----------------
  Future<List<Transaction>> getTransactions({int? limit}) async {
    final db = await database;
    final products = {for (final p in await getProducts()) p.id: p};
    final maps = await db.query(
      'transactions',
      orderBy: 'date_time DESC',
      limit: limit,
    );
    return maps
        .map((m) {
          final prod = products[m['product_id'] as int];
          if (prod == null) return null;
          return Transaction.fromMap(m, prod);
        })
        .whereType<Transaction>()
        .toList();
  }

  Future<int> insertTransaction(Transaction t) async {
    final db = await database;
    return db.insert('transactions', {
      'product_id': t.productId,
      'quantity': t.quantity,
      'total_price': t.totalPrice,
      'date_time': t.dateTime.millisecondsSinceEpoch,
      'note': t.note,
    });
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ----------------- STOCKS -----------------
  Future<List<StockItem>> getStocks() async {
    final db = await database;
    final maps = await db.query('stocks', orderBy: 'category ASC, name ASC');
    return maps.map(StockItem.fromMap).toList();
  }

  Future<int> updateStockQuantity(int id, double quantity) async {
    final db = await database;
    return db.update('stocks', {'quantity': quantity}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> upsertStock(StockItem item) async {
    final db = await database;
    return db.insert('stocks', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ----------------- MATERIALS -----------------
  Future<List<MaterialCost>> getMaterials(int productId) async {
    final db = await database;
    final maps = await db.query('materials', where: 'product_id = ?', whereArgs: [productId]);
    return maps.map(MaterialCost.fromMap).toList();
  }

  Future<void> replaceMaterials(int productId, List<MaterialCost> materials) async {
    final db = await database;
    await db.delete('materials', where: 'product_id = ?', whereArgs: [productId]);
    final Batch batch = db.batch();
    for (final m in materials) {
      batch.insert('materials', {
        'product_id': productId,
        'name': m.name,
        'cost': m.cost,
        'emoji': m.emoji,
      });
    }
    await batch.commit();
  }

  /// Recalculate & update HPP produk berdasarkan total materials.
  Future<void> recalcProductHpp(int productId) async {
    final materials = await getMaterials(productId);
    final int total = materials.fold(0, (sum, m) => sum + m.cost);
    final prod = await getProduct(productId);
    if (prod != null) {
      await upsertProduct(prod.copyWith(hpp: total));
    }
  }
}
