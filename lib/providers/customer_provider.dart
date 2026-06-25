import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerProvider() {
    _load();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Customer> _items = [];
  List<Customer> get items => _items;
  bool _loading = true;
  bool get loading => _loading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Customer> get rankedItems {
    final source = _searchQuery.isNotEmpty
        ? _items.where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (c.whatsapp?.contains(_searchQuery) ?? false) ||
            (c.note?.toLowerCase().contains(_searchQuery) ?? false))
        : _items;
    final sorted = List<Customer>.from(source)
      ..sort((a, b) => b.totalPurchase.compareTo(a.totalPurchase));
    return sorted;
  }

  Future<void> _load() async {
    try {
      _items = await _db.getCustomers();
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

  Future<int> add(Customer customer) async {
    final id = await _db.insertCustomer(customer);
    await refresh();
    return id;
  }

  Future<void> update(Customer customer) async {
    await _db.updateCustomer(customer);
    await refresh();
  }

  Future<void> remove(int id) async {
    await _db.deleteCustomer(id);
    await refresh();
  }

  Future<Customer?> getDetail(int id) async {
    return _db.getCustomer(id);
  }
}
