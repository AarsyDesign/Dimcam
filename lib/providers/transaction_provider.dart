import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/transaction.dart';

/// 💰 Provider transaksi penjualan — CRUD + pencarian + pagination.
class TransactionProvider extends ChangeNotifier {
  TransactionProvider() {
    _loadPage();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  static const int _pageSize = 20;

  List<Transaction> _items = [];
  List<Transaction> get items => _items;
  bool _loading = true;
  bool get loading => _loading;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  int _page = 0;

  String _query = '';
  String get query => _query;

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool get hasDateFilter => _startDate != null || _endDate != null;

  Future<void> _loadPage() async {
    try {
      final newItems = await _db.getTransactions(
        limit: _pageSize,
        offset: _page * _pageSize,
        query: _query.isEmpty ? null : _query,
        startDate: _startDate,
        endDate: _endDate,
      );
      _hasMore = newItems.length == _pageSize;
      if (_page == 0) {
        _items = newItems;
      } else {
        _items = [..._items, ...newItems];
      }
    } catch (_) {
      if (_page == 0) _items = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loading || !_hasMore) return;
    _loading = true;
    notifyListeners();
    _page++;
    await _loadPage();
  }

  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    _loading = true;
    notifyListeners();
    await _loadPage();
  }

  Future<void> setQuery(String q) async {
    _query = q.trim();
    await refresh();
  }

  Future<void> clearQuery() async {
    _query = '';
    await refresh();
  }

  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    _startDate = start;
    _endDate = end;
    await refresh();
  }

  Future<void> clearDateRange() async {
    _startDate = null;
    _endDate = null;
    await refresh();
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
    int sum = 0;
    for (final t in all) {
      if (t.dateTime.year == now.year &&
          t.dateTime.month == now.month &&
          t.dateTime.day == now.day) {
        sum += t.totalPrice;
      }
    }
    return sum;
  }
}
