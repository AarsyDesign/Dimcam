import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' hide Transaction;

import '../dummy/dummy_data.dart';
import '../models/bahan.dart';
import '../models/customer.dart';
import '../models/debt.dart';
import '../models/product.dart';
import '../models/production.dart';
import '../models/resep_item.dart';
import '../models/stock_transaction.dart';
import '../models/transaction.dart';

/// 🗄️ Helper SQLite untuk Dimsumia Manager.
///
/// Skema: products, bahans, resep_items, transactions.
/// HPP produk dihitung dari resep (Σ hargaBeli × qtyUsed), bukan kolom statis.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'dimsumia.db';
  static const int _dbVersion = 6;

  Database? _db;
  bool _seeded = false;

  /// Untuk test — inject database langsung.
  @visibleForTesting
  static set testDb(Database? db) => instance._db = db;

  /// Reset singleton untuk test isolation.
  @visibleForTesting
  static void resetForTest() {
    instance._db?.close();
    instance._db = null;
    instance._seeded = false;
  }

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
        note TEXT,
        customer_id INTEGER,
        customer_name TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE stock_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bahan_id INTEGER NOT NULL,
        bahan_name TEXT NOT NULL,
        type INTEGER NOT NULL,
        quantity REAL NOT NULL,
        note TEXT,
        date_time INTEGER NOT NULL,
        product_id INTEGER,
        product_name TEXT,
        FOREIGN KEY (bahan_id) REFERENCES bahans(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE productions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_emoji TEXT NOT NULL DEFAULT '🥟',
        quantity INTEGER NOT NULL,
        total_cost INTEGER NOT NULL,
        date_time INTEGER NOT NULL,
        note TEXT,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE production_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        production_id INTEGER NOT NULL,
        bahan_id INTEGER NOT NULL,
        bahan_name TEXT NOT NULL,
        bahan_emoji TEXT,
        qty_used REAL NOT NULL,
        unit TEXT NOT NULL,
        cost INTEGER NOT NULL,
        FOREIGN KEY (production_id) REFERENCES productions(id) ON DELETE CASCADE,
        FOREIGN KEY (bahan_id) REFERENCES bahans(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        whatsapp TEXT,
        amount INTEGER NOT NULL,
        date_time INTEGER NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        note TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        whatsapp TEXT,
        address TEXT,
        note TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await batch.commit();
    await _seed(db);
  }

  /// Bila versi naik & skema berubah total, reset untuk dev.
  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    // Drop semua & recreate untuk memastikan dummy segar.
    await db.execute('DROP TABLE IF EXISTS customers');
    await db.execute('DROP TABLE IF EXISTS debts');
    await db.execute('DROP TABLE IF EXISTS production_details');
    await db.execute('DROP TABLE IF EXISTS productions');
    await db.execute('DROP TABLE IF EXISTS stock_transactions');
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

    // Seed pelanggan dummy.
    final now = DateTime.now();
    final customerData = [
      {'name': 'Budi Santoso', 'whatsapp': '081234567890', 'address': 'Jl. Merdeka No. 10', 'note': 'Pelanggan tetap'},
      {'name': 'Siti Rahayu', 'whatsapp': '085678901234', 'address': 'Jl. Sudirman No. 25', 'note': null},
      {'name': 'Ahmad Hidayat', 'whatsapp': '087890123456', 'address': 'Jl. Gatot Subroto No. 5', 'note': 'Kantor'},
      {'name': 'Dewi Lestari', 'whatsapp': '081345678901', 'address': 'Jl. Diponegoro No. 15', 'note': 'Langganan catering'},
    ];
    for (final c in customerData) {
      await db.insert('customers', {
        'name': c['name'],
        'whatsapp': c['whatsapp'],
        'address': c['address'],
        'note': c['note'],
        'created_at': now.millisecondsSinceEpoch,
      });
    }

    // Transaksi.
    final customerRows = await db.query('customers');
    final Map<int, int> customerIds = {};
    for (int i = 0; i < customerRows.length; i++) {
      // Map index-based assignment: customer 0 = Budi, 1 = Siti, etc.
      customerIds[i] = customerRows[i]['id'] as int;
    }

    final Batch txBatch = db.batch();
    final txCustomerMap = [0, 1, 2, 0, 1, 3, 2, 0, 1, 2, 0, 3, 1, 0, 2]; // index per transaksi
    for (int i = 0; i < DummyData.transactions.length; i++) {
      final t = DummyData.transactions[i];
      final cId = customerIds[txCustomerMap[i]];
      final cName = customerData[txCustomerMap[i]]['name'] as String;
      txBatch.insert('transactions', {
        'product_id': t.productId,
        'product_name': t.productName,
        'product_emoji': t.productEmoji,
        'quantity': t.quantity,
        'unit_price': t.unitPrice,
        'hpp_per_unit': t.hppPerUnit,
        'date_time': t.dateTime.millisecondsSinceEpoch,
        'note': t.note,
        'customer_id': cId,
        'customer_name': cName,
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
  Future<List<Bahan>> getBahans({int? limit, int? offset}) async {
    final db = await database;
    final maps = await db.query('bahans', orderBy: 'category ASC, name ASC', limit: limit, offset: offset);
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
  Future<List<Transaction>> getTransactions({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
    String? query,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (startDate != null) {
      conditions.add('date_time >= ?');
      args.add(startDate.millisecondsSinceEpoch);
    }
    if (endDate != null) {
      conditions.add('date_time <= ?');
      args.add(endDate.millisecondsSinceEpoch);
    }
    if (query != null && query.isNotEmpty) {
      conditions.add('(product_name LIKE ? OR note LIKE ?)');
      args.addAll(['%$query%', '%$query%']);
    }

    final where = conditions.isEmpty ? null : conditions.join(' AND ');
    final maps = await db.query(
      'transactions',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date_time DESC',
      limit: limit,
      offset: offset,
    );
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

  // ----------------- STOCK TRANSACTIONS -----------------
  Future<List<StockTransaction>> getStockTransactions({int? bahanId, int? limit}) async {
    final db = await database;
    final maps = await db.query(
      'stock_transactions',
      where: bahanId != null ? 'bahan_id = ?' : null,
      whereArgs: bahanId != null ? [bahanId] : null,
      orderBy: 'date_time DESC',
      limit: limit,
    );
    return maps.map(StockTransaction.fromMap).toList();
  }

  Future<int> insertStockTransaction(StockTransaction st) async {
    final db = await database;
    return db.insert('stock_transactions', st.toMap());
  }

  /// Pembelian bahan: tambah stok + catat histori.
  Future<void> purchaseBahan(int bahanId, String bahanName, double qty, String? note) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE bahans SET stock = stock + ? WHERE id = ?',
        [qty, bahanId],
      );
      await txn.insert('stock_transactions', {
        'bahan_id': bahanId,
        'bahan_name': bahanName,
        'type': StockTransactionType.purchase.index,
        'quantity': qty,
        'note': note,
        'date_time': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  /// Produksi: kurangi stok bahan sesuai resep + catat histori.
  Future<void> produceBahan(int productId, String productName, int qty) async {
    final db = await database;
    await db.transaction((txn) async {
      final resep = await txn.query('resep_items', where: 'product_id = ?', whereArgs: [productId]);
      
      for (final r in resep) {
        final bahanId = r['bahan_id'] as int;
        final qtyUsed = (r['qty_used'] as num).toDouble();
        final totalUsed = qtyUsed * qty;

        final bahanRows = await txn.query('bahans', where: 'id = ?', whereArgs: [bahanId]);
        if (bahanRows.isEmpty) continue;
        
        final bahanName = bahanRows.first['name'] as String;

        await txn.rawUpdate(
          'UPDATE bahans SET stock = MAX(0, stock - ?) WHERE id = ?',
          [totalUsed, bahanId],
        );

        await txn.insert('stock_transactions', {
          'bahan_id': bahanId,
          'bahan_name': bahanName,
          'type': StockTransactionType.production.index,
          'quantity': -totalUsed,
          'note': 'Produksi $qty $productName',
          'date_time': DateTime.now().millisecondsSinceEpoch,
          'product_id': productId,
          'product_name': productName,
        });
      }
    });
  }

  /// Penyesuaian stok manual.
  Future<void> adjustStock(int bahanId, String bahanName, double delta, String? note) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE bahans SET stock = MAX(0, stock + ?) WHERE id = ?',
        [delta, bahanId],
      );
      await txn.insert('stock_transactions', {
        'bahan_id': bahanId,
        'bahan_name': bahanName,
        'type': StockTransactionType.adjustment.index,
        'quantity': delta,
        'note': note,
        'date_time': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  // ----------------- PRODUCTION -----------------
  /// Validasi stok bahan cukup untuk produksi.
  Future<Map<String, dynamic>> checkProductionStock(int productId, int qty) async {
    final db = await database;
    final resep = await db.query('resep_items', where: 'product_id = ?', whereArgs: [productId]);
    
    final insufficient = <Map<String, dynamic>>[];
    int totalCost = 0;

    for (final r in resep) {
      final bahanId = r['bahan_id'] as int;
      final qtyUsed = (r['qty_used'] as num).toDouble();
      final totalNeeded = qtyUsed * qty;

      final bahanRows = await db.query('bahans', where: 'id = ?', whereArgs: [bahanId]);
      if (bahanRows.isEmpty) continue;

      final bahan = bahanRows.first;
      final bahanName = bahan['name'] as String;
      final bahanStock = (bahan['stock'] as num).toDouble();
      final bahanPrice = (bahan['buy_price'] as num).toInt();
      final bahanUnit = bahan['unit'] as String;

      totalCost += (bahanPrice * totalNeeded).round();

      if (bahanStock < totalNeeded) {
        insufficient.add({
          'name': bahanName,
          'needed': totalNeeded,
          'available': bahanStock,
          'unit': bahanUnit,
        });
      }
    }

    return {
      'sufficient': insufficient.isEmpty,
      'insufficient': insufficient,
      'totalCost': totalCost,
    };
  }

  /// Proses produksi lengkap: validasi, kurangi stok, catat produksi + detail.
  Future<int> processProduction(int productId, String productName, String productEmoji, int qty, String? note) async {
    final db = await database;
    
    // Validasi stok
    final check = await checkProductionStock(productId, qty);
    if (!(check['sufficient'] as bool)) {
      throw Exception('Stok bahan tidak mencukupi');
    }

    int productionId = 0;

    await db.transaction((txn) async {
      final resep = await txn.query('resep_items', where: 'product_id = ?', whereArgs: [productId]);
      
      // Insert production header
      productionId = await txn.insert('productions', {
        'product_id': productId,
        'product_name': productName,
        'product_emoji': productEmoji,
        'quantity': qty,
        'total_cost': check['totalCost'] as int,
        'date_time': DateTime.now().millisecondsSinceEpoch,
        'note': note,
      });

      // Process each bahan
      for (final r in resep) {
        final bahanId = r['bahan_id'] as int;
        final qtyUsed = (r['qty_used'] as num).toDouble();
        final totalUsed = qtyUsed * qty;

        final bahanRows = await txn.query('bahans', where: 'id = ?', whereArgs: [bahanId]);
        if (bahanRows.isEmpty) continue;

        final bahan = bahanRows.first;
        final bahanName = bahan['name'] as String;
        final bahanEmoji = bahan['emoji'] as String?;
        final bahanUnit = bahan['unit'] as String;
        final bahanPrice = (bahan['buy_price'] as num).toInt();
        final itemCost = (bahanPrice * totalUsed).round();

        // Kurangi stok
        await txn.rawUpdate(
          'UPDATE bahans SET stock = stock - ? WHERE id = ?',
          [totalUsed, bahanId],
        );

        // Insert production detail
        await txn.insert('production_details', {
          'production_id': productionId,
          'bahan_id': bahanId,
          'bahan_name': bahanName,
          'bahan_emoji': bahanEmoji,
          'qty_used': totalUsed,
          'unit': bahanUnit,
          'cost': itemCost,
        });

        // Insert stock transaction
        await txn.insert('stock_transactions', {
          'bahan_id': bahanId,
          'bahan_name': bahanName,
          'type': StockTransactionType.production.index,
          'quantity': -totalUsed,
          'note': 'Produksi $qty $productName',
          'date_time': DateTime.now().millisecondsSinceEpoch,
          'product_id': productId,
          'product_name': productName,
        });
      }
    });

    return productionId;
  }

  /// Get all productions.
  Future<List<Production>> getProductions({int? limit, int? offset}) async {
    final db = await database;
    final maps = await db.query('productions', orderBy: 'date_time DESC', limit: limit, offset: offset);
    return maps.map(Production.fromMap).toList();
  }

  /// Get production by id.
  Future<Production?> getProduction(int id) async {
    final db = await database;
    final maps = await db.query('productions', where: 'id = ?', whereArgs: [id]);
    return maps.isEmpty ? null : Production.fromMap(maps.first);
  }

  /// Get production details.
  Future<List<ProductionDetail>> getProductionDetails(int productionId) async {
    final db = await database;
    final maps = await db.query('production_details', where: 'production_id = ?', whereArgs: [productionId]);
    return maps.map(ProductionDetail.fromMap).toList();
  }

  /// Delete production (cascade akan hapus details).
  Future<int> deleteProduction(int id) async {
    final db = await database;
    return db.delete('productions', where: 'id = ?', whereArgs: [id]);
  }

  // ----------------- DEBTS -----------------
  Future<List<Debt>> getDebts({DebtStatus? status}) async {
    final db = await database;
    final maps = await db.query(
      'debts',
      where: status != null ? 'status = ?' : null,
      whereArgs: status != null ? [status.index] : null,
      orderBy: 'date_time DESC',
    );
    return maps.map(Debt.fromMap).toList();
  }

  Future<int> insertDebt(Debt debt) async {
    final db = await database;
    return db.insert('debts', {
      'customer_name': debt.customerName,
      'whatsapp': debt.whatsapp,
      'amount': debt.amount,
      'date_time': debt.dateTime.millisecondsSinceEpoch,
      'status': debt.status.index,
      'note': debt.note,
    });
  }

  Future<int> updateDebt(Debt debt) async {
    final db = await database;
    return db.update('debts', {
      'customer_name': debt.customerName,
      'whatsapp': debt.whatsapp,
      'amount': debt.amount,
      'date_time': debt.dateTime.millisecondsSinceEpoch,
      'status': debt.status.index,
      'note': debt.note,
    }, where: 'id = ?', whereArgs: [debt.id]);
  }

  Future<int> deleteDebt(int id) async {
    final db = await database;
    return db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Debt>> searchDebts(String query) async {
    final db = await database;
    final maps = await db.query(
      'debts',
      orderBy: 'date_time DESC',
      where: 'customer_name LIKE ? OR note LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map(Debt.fromMap).toList();
  }

  /// Total nominal piutang (belum lunas).
  Future<int> getTotalPiutang() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM debts WHERE status = ?',
      [DebtStatus.unpaid.index],
    );
    return (result.first['total'] as num).toInt();
  }

  /// Total nominal piutang lunas.
  Future<int> getTotalLunas() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM debts WHERE status = ?',
      [DebtStatus.paid.index],
    );
    return (result.first['total'] as num).toInt();
  }

  /// Jumlah pelanggan yang belum lunas.
  Future<int> getJumlahPiutang() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM debts WHERE status = ?',
      [DebtStatus.unpaid.index],
    );
    return (result.first['count'] as num).toInt();
  }

  /// Total nominal piutang yang jatuh tempo (> 30 hari dan belum lunas).
  Future<int> getTotalJatuhTempo() async {
    final db = await database;
    final cutoff = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM debts WHERE status = ? AND date_time <= ?',
      [DebtStatus.unpaid.index, cutoff],
    );
    return (result.first['total'] as num).toInt();
  }

  // ----------------- CUSTOMERS -----------------
  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT c.*,
        COUNT(t.id) AS total_transactions,
        COALESCE(SUM(t.quantity * t.unit_price), 0) AS total_purchase
      FROM customers c
      LEFT JOIN transactions t ON t.customer_id = c.id
      GROUP BY c.id
      ORDER BY total_purchase DESC
    ''');
    return maps.map((m) {
      final c = Customer.fromMap(m);
      c.totalTransactions = (m['total_transactions'] as num).toInt();
      c.totalPurchase = (m['total_purchase'] as num).toInt();
      return c;
    }).toList();
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT c.*,
        COUNT(t.id) AS total_transactions,
        COALESCE(SUM(t.quantity * t.unit_price), 0) AS total_purchase
      FROM customers c
      LEFT JOIN transactions t ON t.customer_id = c.id
      WHERE c.name LIKE ? OR c.whatsapp LIKE ? OR c.note LIKE ?
      GROUP BY c.id
      ORDER BY total_purchase DESC
    ''', ['%$query%', '%$query%', '%$query%']);
    return maps.map((m) {
      final c = Customer.fromMap(m);
      c.totalTransactions = (m['total_transactions'] as num).toInt();
      c.totalPurchase = (m['total_purchase'] as num).toInt();
      return c;
    }).toList();
  }

  Future<Customer?> getCustomer(int id) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT c.*,
        COUNT(t.id) AS total_transactions,
        COALESCE(SUM(t.quantity * t.unit_price), 0) AS total_purchase
      FROM customers c
      LEFT JOIN transactions t ON t.customer_id = c.id
      WHERE c.id = ?
      GROUP BY c.id
    ''', [id]);
    if (maps.isEmpty) return null;
    final m = maps.first;
    final c = Customer.fromMap(m);
    c.totalTransactions = (m['total_transactions'] as num).toInt();
    c.totalPurchase = (m['total_purchase'] as num).toInt();

    // Favorite product
    final fav = await db.rawQuery('''
      SELECT product_name, product_emoji, SUM(quantity) AS total_qty
      FROM transactions
      WHERE customer_id = ?
      GROUP BY product_id
      ORDER BY total_qty DESC
      LIMIT 1
    ''', [id]);
    if (fav.isNotEmpty) {
      c.favoriteProduct = fav.first['product_name'] as String?;
      c.favoriteProductEmoji = fav.first['product_emoji'] as String?;
    }

    return c;
  }

  Future<int> insertCustomer(Customer c) async {
    final db = await database;
    return db.insert('customers', {
      'name': c.name,
      'whatsapp': c.whatsapp,
      'address': c.address,
      'note': c.note,
      'created_at': (c.createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    });
  }

  Future<int> updateCustomer(Customer c) async {
    final db = await database;
    return db.update('customers', {
      'name': c.name,
      'whatsapp': c.whatsapp,
      'address': c.address,
      'note': c.note,
    }, where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> deleteCustomer(int id) async {
    // Unlink transactions
    final db = await database;
    await db.update('transactions', {'customer_id': null, 'customer_name': null},
        where: 'customer_id = ?', whereArgs: [id]);
    return db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  /// Tutup database (untuk backup/restore).
  Future<void> close() async {
    final db = _db;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _db = null;
  }

  /// Buka ulang database setelah restore.
  Future<void> reopen() async {
    _seeded = true; // jangan re-seed, data sudah ada dari restore
    _db = null;
    await database; // trigger _initDb
  }
}

