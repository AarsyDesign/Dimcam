import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/production.dart';

class ProductionProvider extends ChangeNotifier {
  ProductionProvider({bool autoLoad = true}) {
    if (autoLoad) _load();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Production> _items = [];
  List<Production> get items => _items;

  @visibleForTesting
  set items(List<Production> value) => _items = value;
  bool _loading = true;
  bool get loading => _loading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Production> get filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items.where((p) =>
      p.productName.toLowerCase().contains(q) ||
      (p.note?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  Future<void> _load() async {
    try {
      _items = await _db.getProductions();
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

  Future<int> process(
    int productId,
    String productName,
    String productEmoji,
    int qty,
    String? note,
  ) async {
    final id = await _db.processProduction(productId, productName, productEmoji, qty, note);
    await refresh();
    return id;
  }

  Future<void> remove(int id) async {
    await _db.deleteProduction(id);
    await refresh();
  }

  Future<Map<String, dynamic>> checkStock(int productId, int qty) async {
    return await _db.checkProductionStock(productId, qty);
  }

  List<Production> get today {
    final now = DateTime.now();
    return _items
        .where((p) =>
            p.dateTime.year == now.year &&
            p.dateTime.month == now.month &&
            p.dateTime.day == now.day)
        .toList();
  }

  int get totalProductionToday {
    return today.fold(0, (sum, p) => sum + p.quantity);
  }

  int get totalCostToday {
    return today.fold(0, (sum, p) => sum + p.totalCost);
  }
}
