import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/bahan.dart';

/// 🧂 Provider master bahan (sekalian stok & harga beli).
class BahanProvider extends ChangeNotifier {
  BahanProvider() {
    _load();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Bahan> _items = [];
  List<Bahan> get items => _items;
  bool _loading = true;
  bool get loading => _loading;

  Future<void> _load() async {
    try {
      _items = await _db.getBahans();
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
