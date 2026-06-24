import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../dummy/dummy_data.dart';
import '../models/bahan.dart';
import '../models/product.dart';
import '../models/resep_item.dart';
import '../models/transaction.dart';

/// 🗄️ Helper SQLite untuk Dimsumia Manager.
///
/// Skema: products, bahans, resep_items, transactions.
/// HPP produk dihitung dari resep (Σ hargaBeli × qtyUsed), bukan kolom statis.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'dimsumia.db';
  static const int _dbVersion = 2;

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
      onUpgrade: _onUpgrade,
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
        unit TEXT NOT NULL DEFAULT 'pcs',
        description TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE bahans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        unit TEXT NOT NULL DEFAULT 'pcs',
        buy_price INTEGER NOT NULL DEFAULT 0,
        stock REAL NOT NULL DEFAULT 0,
        min_stock REAL NOT NULL DEFAULT 0,
        emoji TEXT,
        category TEXT NOT NULL DEFAULT 'Bahan'
      )
    ''');

    batch.execute('''
      CREATE TABLE resep_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        bahan_id INTEGER NOT NULL,
        qty_used REAL NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
        FOREIGN KEY (bahan_id) REFERENCES bahans(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_emoji TEXT NOT NULL DEFAULT '🥟',
        quantity INTEGER NOT NULL,
        unit_price INTEGER NOT NULL,
        hpp_per_unit INTEGER NOT NULL,
        date_time INTEGER NOT NULL,
        note TEXT
      )
    ''');

    await batch.commit();
    await _seed(db);
  }

  /// Bila versi naik & skema berubah total, reset untuk dev.
  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    // Drop semua & recreate untuk memastikan dummy segar.
    await db.execute('DROP TABLE IF EXISTS transactions');
    await db.execute('DROP TABLE IF EXISTS resep_items');
    await db.execute('DROP TABLE IF EXISTS bahans');
    await db.execute('DROP TABLE IF EXISTS products');
    _seeded = false;
    await _onCreate(db, newV);
  }

  /// Seed data dummy pada database baru.
  Future<void> _seed(Database db) async {
    if (_seeded) return;
    final Batch batch = db.batch();

    for (final Product prod in DummyData.products) {
      batch.insert('products', prod.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    // Bahan: tanpa id (AUTOINCREMENT) — pakai nama sebagai patokan.
    for (final Bahan b in DummyData.bahans) {
      batch.insert('bahans', {
        'name': b.name,
        'unit': b.unit,
        'buy_price': b.buyPrice,
        'stock': b.stock,
        'min_stock': b.minStock,
        'emoji': b.emoji,
        'category': b.category,
      });
    }

    await batch.commit();

    // Petakan nama bahan → id hasil insert.
    final bahanRows = await db.query('bahans');
    final Map<String, int> bahanIdByName = {
      for (final r in bahanRows) r['name'] as String: r['id'] as int,
    };

    final Batch resepBatch = db.batch();
    for (final ResepItem r in DummyData.resepItems) {
      final bahanId = bahanIdByName[DummyData.bahans.firstWhere((b) => b.id == r.bahanId).name];
      if (bahanId != null) {
        resepBatch.insert('resep_items', {
          'product_id': r.productId,
          'bahan_id': bahanId,
          'qty_used': r.qtyUsed,
        });
      }
    }
    await resepBatch.commit();

    // Transaksi.
    final Batch txBatch = db.batch();
    for (final Transaction t in DummyData.transactions) {
      txBatch.insert('transactions', {
        'product_id': t.productId,
        'product_name': t.productName,
        'product_emoji': t.productEmoji,
        'quantity': t.quantity,
        'unit_price': t.unitPrice,
        'hpp_per_unit': t.hppPerUnit,
        'date_time': t.dateTime.millisecondsSinceEpoch,
        'note': t.note,
      });
    }
    await txBatch.commit();
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

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  /// Id produk berikutnya (untuk insert manual dengan id stabil).
  Future<int> nextProductId() async {
    final db = await database;
    final rows = await db.rawQuery('SELECT MAX(id) AS m FROM products');
    final m = rows.first['m'];
    return (m == null ? 0 : (m as int)) + 1;
  }

  // ----------------- BAHAN -----------------
  Future<List<Bahan>> getBahans() async {
    final db = await database;
    final maps = await db.query('bahans', orderBy: 'category ASC, name ASC');
    return maps.map(Bahan.fromMap).toList();
  }

  Future<int> insertBahan(Bahan b) async {
    final db = await database;
    return db.insert('bahans', {
      'name': b.name,
      'unit': b.unit,
      'buy_price': b.buyPrice,
      'stock': b.stock,
      'min_stock': b.minStock,
      'emoji': b.emoji,
      'category': b.category,
    });
  }

  Future<int> updateBahan(Bahan b) async {
    final db = await database;
    return db.update('bahans', {
      'name': b.name,
      'unit': b.unit,
      'buy_price': b.buyPrice,
      'stock': b.stock,
      'min_stock': b.minStock,
      'emoji': b.emoji,
      'category': b.category,
    }, where: 'id = ?', whereArgs: [b.id]);
  }

  Future<int> deleteBahan(int id) async {
    final db = await database;
    return db.delete('bahans', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> adjustBahanStock(int id, double delta) async {
    final db = await database;
    final rows = await db.query('bahans', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final current = (rows.first['stock'] as num).toDouble();
    await db.update('bahans', {'stock': (current + delta).clamp(0, double.infinity)},
        where: 'id = ?', whereArgs: [id]);
  }

  // ----------------- RESEP -----------------
  Future<List<ResepItem>> getResep(int productId) async {
    final db = await database;
    final maps = await db.query('resep_items', where: 'product_id = ?', whereArgs: [productId]);
    return maps.map(ResepItem.fromMap).toList();
  }

  Future<void> replaceResep(int productId, List<ResepItem> items) async {
    final db = await database;
    await db.delete('resep_items', where: 'product_id = ?', whereArgs: [productId]);
    final Batch batch = db.batch();
    for (final i in items) {
      batch.insert('resep_items', {
        'product_id': productId,
        'bahan_id': i.bahanId,
        'qty_used': i.qtyUsed,
      });
    }
    await batch.commit();
  }

  /// Hitung HPP sebuah produk dari resep + harga bahan.
  Future<int> calcHpp(int productId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT COALESCE(SUM(b.buy_price * r.qty_used), 0) AS hpp
      FROM resep_items r
      JOIN bahans b ON b.id = r.bahan_id
      WHERE r.product_id = ?
    ''', [productId]);
    return (rows.first['hpp'] as num).round();
  }

  // ----------------- TRANSACTIONS -----------------
  Future<List<Transaction>> getTransactions({int? limit}) async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date_time DESC', limit: limit);
    return maps.map(Transaction.fromMap).toList();
  }

  Future<Transaction?> getTransaction(int id) async {
    final db = await database;
    final maps = await db.query('transactions', where: 'id = ?', whereArgs: [id]);
    return maps.isEmpty ? null : Transaction.fromMap(maps.first);
  }

  Future<int> insertTransaction(Transaction t) async {
    final db = await database;
    return db.insert('transactions', {
      'product_id': t.productId,
      'product_name': t.productName,
      'product_emoji': t.productEmoji,
      'quantity': t.quantity,
      'unit_price': t.unitPrice,
      'hpp_per_unit': t.hppPerUnit,
      'date_time': t.dateTime.millisecondsSinceEpoch,
      'note': t.note,
    });
  }

  Future<int> updateTransaction(Transaction t) async {
    final db = await database;
    return db.update('transactions', {
      'product_id': t.productId,
      'product_name': t.productName,
      'product_emoji': t.productEmoji,
      'quantity': t.quantity,
      'unit_price': t.unitPrice,
      'hpp_per_unit': t.hppPerUnit,
      'date_time': t.dateTime.millisecondsSinceEpoch,
      'note': t.note,
    }, where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Pencarian transaksi berdasarkan nama produk / catatan.
  Future<List<Transaction>> searchTransactions(String query) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date_time DESC',
      where: 'product_name LIKE ? OR note LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map(Transaction.fromMap).toList();
  }
}
