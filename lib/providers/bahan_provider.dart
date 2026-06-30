import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/bahan.dart';

/// 🧂 Provider master bahan (sekalian stok & harga beli).
class BahanProvider extends ChangeNotifier {
  BahanProvider({bool autoLoad = true}) {
    if (autoLoad) _load();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  static const int _pageSize = 20;

  /// Semua bahan (untuk dropdown).
  List<Bahan> _all = [];
  List<Bahan> get all => _all;

  /// Bahan paginated (untuk list).
  List<Bahan> _items = [];
  List<Bahan> get items => _items;

  @visibleForTesting
  set items(List<Bahan> value) => _items = value;
  bool _loading = true;
  bool get loading => _loading;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  int _page = 0;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Bahan> get filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items.where((b) =>
      b.name.toLowerCase().contains(q) ||
      b.category.toLowerCase().contains(q)
    ).toList();
  }

  /// Muat semua bahan (untuk dropdown form).
  Future<void> _load() async {
    try {
      _all = await _db.getBahans();
    } catch (_) {
      _all = [];
    }
  }

  /// Muat halaman pertama (untuk list).
  Future<void> _loadPage() async {
    try {
      final newItems = await _db.getBahans(limit: _pageSize, offset: _page * _pageSize);
      _hasMore = newItems.length == _pageSize;
      _items = newItems;
      _all = [..._all, ...newItems];
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
    try {
      final newItems = await _db.getBahans(limit: _pageSize, offset: _page * _pageSize);
      _hasMore = newItems.length == _pageSize;
      _items = [..._items, ...newItems];
      _all = [..._all, ...newItems];
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    _loading = true;
    notifyListeners();
    await _load();
    await _loadPage();
  }

  Bahan? byId(int id) {
    try {
      return _items.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(Bahan b) async {
    await _db.insertBahan(b);
    await refresh();
  }

  Future<void> update(Bahan b) async {
    await _db.updateBahan(b);
    await refresh();
  }

  Future<void> remove(int id) async {
    await _db.deleteBahan(id);
    await refresh();
  }

  /// Tambah / kurang stok.
  Future<void> adjust(int id, double delta) async {
    await _db.adjustBahanStock(id, delta);
    await refresh();
  }

  /// Set stok absolut.
  Future<void> setStock(int id, double value) async {
    final b = byId(id);
    if (b == null) return;
    await _db.updateBahan(b.copyWith(stock: value));
    await refresh();
  }

  List<Bahan> get lowStock => _items.where((b) => b.isLow || b.isOut).toList();
}
