import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/transaction.dart';

/// 💰 Provider transaksi penjualan — CRUD + pencarian.
class TransactionProvider extends ChangeNotifier {
  TransactionProvider() {
    _load();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Transaction> _items = [];
  List<Transaction> get items => _items;
  bool _loading = true;
  bool get loading => _loading;

  String _query = '';
  String get query => _query;

  Future<void> _load() async {
    try {
      if (_query.isEmpty) {
        _items = await _db.getTransactions();
      } else {
        _items = await _db.searchTransactions(_query);
      }
    } catch (_) {
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

  Future<void> setQuery(String q) async {
    _query = q.trim();
    await _load();
  }

  Future<void> clearQuery() async {
    _query = '';
    await _load();
  }

  Future<void> add(Transaction t) async {
    await _db.insertTransaction(t);
    await refresh();
  }

  Future<void> update(Transaction t) async {
    await _db.updateTransaction(t);
    await refresh();
  }

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

  /// Total penjualan hari ini (semua item, abaikan query pencarian).
  Future<int> totalSalesToday() async {
    final all = await _db.getTransactions();
    final now = DateTime.now();
    return all
        .where((t) =>
            t.dateTime.year == now.year &&
            t.dateTime.month == now.month &&
            t.dateTime.day == now.day)
        .fold(0, (s, t) => s + t.totalPrice);
  }
}
