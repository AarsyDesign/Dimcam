import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/bahan.dart';
import '../data/models/product.dart';
import '../data/models/resep_item.dart';

/// 🧮 Provider HPP — mengelola resep produk & menghitung biaya/HPP/margin.
class HppProvider extends ChangeNotifier {
  HppProvider();

  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Resep aktif tiap produk (productId → list item).
  final Map<int, List<ResepItem>> _resep = {};
  /// Snapshot HPP tiap produk.
  final Map<int, int> _hppCache = {};

  bool _loading = false;
  bool get loading => _loading;

  List<ResepItem> resepOf(int productId) => _resep[productId] ?? const [];
  int hppOf(int productId) => _hppCache[productId] ?? 0;

  /// Muat resep & HPP semua produk (dipanggil sekali saat init HPP screen).
  Future<void> loadAll(Iterable<int> productIds) async {
    _loading = true;
    notifyListeners();
    for (final id in productIds) {
      await load(id, notify: false);
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> load(int productId, {bool notify = true}) async {
    if (notify) {
      _loading = true;
      notifyListeners();
    }
    _resep[productId] = await _db.getResep(productId);
    _hppCache[productId] = await _db.calcHpp(productId);
    if (notify) {
      _loading = false;
      notifyListeners();
    }
  }

  /// Hitung HPP dari daftar bahan + qty (preview live tanpa simpan).
  int previewHpp(List<({int bahanId, double qty})> lines, List<Bahan> bahans) {
    int total = 0;
    for (final line in lines) {
      final b = bahans.firstWhere(
        (b) => b.id == line.bahanId,
        orElse: () => bahans.first,
      );
      total += (b.buyPrice * line.qty).round();
    }
    return total;
  }

  /// Margin absolut.
  int margin(Product p) => p.sellingPrice - hppOf(p.id);

  /// Margin dalam persen.
  double marginPercent(Product p) =>
      p.sellingPrice == 0 ? 0 : (margin(p) / p.sellingPrice) * 100;

  /// Simpan resep produk (replace all).
  Future<void> saveResep(int productId, List<ResepItem> items) async {
    await _db.replaceResep(productId, items);
    await load(productId, notify: false);
    notifyListeners();
  }
}
