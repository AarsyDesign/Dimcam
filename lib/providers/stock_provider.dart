import 'package:flutter/foundation.dart';

import '../data/models/bahan.dart';
import 'bahan_provider.dart';

class StockSummaryItem {
  const StockSummaryItem({
    required this.name,
    required this.emoji,
    required this.quantity,
    required this.unit,
    required this.isOut,
    required this.isLow,
  });

  final String name;
  final String? emoji;
  final double quantity;
  final String unit;
  final bool isOut;
  final bool isLow;
}

class StockProvider extends ChangeNotifier {
  StockProvider() {
    _init();
  }

  BahanProvider? _bahanProvider;

  void _init() {
    // BahanProvider akan diinisialisasi oleh ChangeNotifierProxyProvider
  }

  void init(BahanProvider bahanProvider) {
    _bahanProvider = bahanProvider;
    _bahanProvider!.addListener(_onBahanChanged);
  }

  void _onBahanChanged() {
    notifyListeners();
  }

  List<Bahan> get items => _bahanProvider?.items ?? [];
  bool get loading => _bahanProvider?.loading ?? true;

  List<Bahan> get lowStock => _bahanProvider?.lowStock ?? [];

  int get totalStockItems => items.length;

  List<StockSummaryItem> get lowStockSummary {
    return lowStock.map((b) {
      return StockSummaryItem(
        name: b.name,
        emoji: b.emoji,
        quantity: b.stock,
        unit: b.unit,
        isOut: b.isOut,
        isLow: b.isLow,
      );
    }).toList();
  }

  @override
  void dispose() {
    _bahanProvider?.removeListener(_onBahanChanged);
    super.dispose();
  }
}
