import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/product.dart';

/// 🥟 Provider daftar produk.
class ProductProvider extends ChangeNotifier {
  ProductProvider() {
    _load();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Product> _items = [];
  List<Product> get items => _items;
  bool _loading = true;
  bool get loading => _loading;

  Future<void> _load() async {
    try {
      _items = await _db.getProducts();
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

  Product? byId(int id) {
    try {
      return _items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
