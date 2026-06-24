import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/material_cost.dart';
import '../data/models/product.dart';

/// 🧮 Provider HPP — mengelola bahan & biaya per produk.
class HppProvider extends ChangeNotifier {
  HppProvider();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final Map<int, List<MaterialCost>> _cache = {};
  bool _loading = false;
  bool get loading => _loading;

  List<MaterialCost> materialsOf(int productId) => _cache[productId] ?? const [];

  Future<void> load(int productId) async {
    _loading = true;
    notifyListeners();
    try {
      _cache[productId] = await _db.getMaterials(productId);
    } catch (e) {
      _cache[productId] = [];
    }
    _loading = false;
    notifyListeners();
  }

  /// Total HPP berdasarkan materials (rekalkulasi dari bahan).
  int totalCost(int productId) =>
      materialsOf(productId).fold(0, (sum, m) => sum + m.cost);

  /// Margin berdasarkan rekalkulasi.
  int margin(Product p) => p.sellingPrice - totalCost(p.id);

  Future<void> save(int productId, List<MaterialCost> materials) async {
    await _db.replaceMaterials(productId, materials);
    await _db.recalcProductHpp(productId);
    await load(productId);
  }
}
