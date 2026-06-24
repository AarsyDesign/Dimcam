import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/stock_item.dart';

/// 📦 Provider daftar stok bahan baku.
class StockProvider extends ChangeNotifier {
  StockProvider() {
    _load();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  List<StockItem> _items = [];
  List<StockItem> get items => _items;
  bool _loading = true;
  bool get loading => _loading;

  Future<void> _load() async {
    try {
      _items = await _db.getStocks();
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

  /// Tambah / kurang qty stok.
  Future<void> adjust(int id, double delta) async {
    final item = _items.firstWhere((s) => s.id == id);
    final newQty = (item.quantity + delta).clamp(0, double.infinity);
    await _db.updateStockQuantity(id, newQty);
    await refresh();
  }

  /// Set qty absolut.
  Future<void> setQuantity(int id, double quantity) async {
    await _db.updateStockQuantity(id, quantity);
    await refresh();
  }

  List<StockItem> get lowStock => _items.where((s) => s.isLow || s.isOut).toList();
}
