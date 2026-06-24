import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/transaction.dart';

/// 💰 Provider daftar transaksi penjualan.
class TransactionProvider extends ChangeNotifier {
  TransactionProvider() {
    _load();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Transaction> _items = [];
  List<Transaction> get items => _items;
  bool _loading = true;
  bool get loading => _loading;

  Future<void> _load() async {
    try {
      _items = await _db.getTransactions();
    } catch (e) {
      _items = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await _load();
  }

  /// Tambah transaksi baru.
  Future<void> add(Transaction t) async {
    await _db.insertTransaction(t);
    await refresh();
  }

  /// Hapus transaksi.
  Future<void> remove(int id) async {
    await _db.deleteTransaction(id);
    await refresh();
  }

  /// Transaksi hari ini saja.
  List<Transaction> get today {
    final now = DateTime.now();
    return _items
        .where((t) =>
            t.dateTime.year == now.year &&
            t.dateTime.month == now.month &&
            t.dateTime.day == now.day)
        .toList();
  }
}
