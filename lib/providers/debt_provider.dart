import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/debt.dart';

class DebtProvider extends ChangeNotifier {
  DebtProvider() {
    _load();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Debt> _items = [];
  List<Debt> get items => _items;
  bool _loading = true;
  bool get loading => _loading;

  DebtStatus? _filterStatus;
  DebtStatus? get filterStatus => _filterStatus;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Debt> get filteredItems {
    var result = _items;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((d) =>
          d.customerName.toLowerCase().contains(q) ||
          (d.whatsapp?.contains(q) ?? false) ||
          (d.note?.toLowerCase().contains(q) ?? false)).toList();
    }
    if (_filterStatus != null) {
      result = result.where((d) => d.status == _filterStatus).toList();
    }
    return result;
  }

  int get totalPiutang => _items.where((d) => d.isUnpaid).fold(0, (sum, d) => sum + d.amount);
  int get totalLunas => _items.where((d) => d.isPaid).fold(0, (sum, d) => sum + d.amount);
  int get totalJatuhTempo => _items.where((d) => d.isOverdue).fold(0, (sum, d) => sum + d.amount);
  int get countUnpaid => _items.where((d) => d.isUnpaid).length;
  int get countPaid => _items.where((d) => d.isPaid).length;

  void setFilterStatus(DebtStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> _load() async {
    try {
      _items = await _db.getDebts();
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

  Future<int> add(Debt debt) async {
    final id = await _db.insertDebt(debt);
    await refresh();
    return id;
  }

  Future<void> update(Debt debt) async {
    await _db.updateDebt(debt);
    await refresh();
  }

  Future<void> remove(int id) async {
    await _db.deleteDebt(id);
    await refresh();
  }

  Future<void> markAsPaid(int id) async {
    final debt = _items.firstWhere((d) => d.id == id);
    await _db.updateDebt(debt.copyWith(status: DebtStatus.paid));
    await refresh();
  }
}
