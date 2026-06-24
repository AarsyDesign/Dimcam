import 'package:flutter/foundation.dart';

import '../data/models/bahan.dart';
import '../data/models/transaction.dart';
import 'bahan_provider.dart';
import 'transaction_provider.dart';

/// 📊 Data agregasi dashboard — total penjualan, laba, transaksi, produk terlaris, ringkasan stok.
class DashboardSummary {
  const DashboardSummary({
    required this.totalSalesToday,
    required this.totalProfitToday,
    required this.transactionCountToday,
    required this.bestSeller,
    required this.lowStock,
    required this.totalBahan,
    required this.weeklySales,
  });

  final int totalSalesToday;
  final int totalProfitToday;
  final int transactionCountToday;

  /// Produk terlaris hari ini (null bila belum ada transaksi).
  final BestSeller? bestSeller;

  final List<Bahan> lowStock;
  final int totalBahan;

  /// Penjualan 7 hari terakhir (index 0 = 6 hari lalu, 6 = hari ini).
  final List<DailySales> weeklySales;
}

class BestSeller {
  const BestSeller({required this.name, required this.emoji, required this.qty, required this.revenue});
  final String name;
  final String emoji;
  final int qty;
  final int revenue;
}

class DailySales {
  const DailySales({required this.date, required this.total, required this.count});
  final DateTime date;
  final int total;
  final int count;
}

/// 🏠 Provider dashboard — menghitung ringkasan dari transaksi & bahan.
class DashboardProvider extends ChangeNotifier {
  DashboardProvider();

  DashboardSummary? _summary;
  DashboardSummary? get summary => _summary;
  bool _loading = false;
  bool get loading => _loading;

  /// Hitung ulang ringkasan dari provider turunan.
  void recompute({
    required TransactionProvider transactions,
    required BahanProvider bahans,
  }) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayTx = transactions.items.where(
        (t) => !t.dateTime.isBefore(todayStart) && t.dateTime.isBefore(todayStart.add(const Duration(days: 1))));

    int totalSales = 0;
    int totalProfit = 0;
    final Map<int, int> qtyPerProduct = {};
    final Map<int, int> revenuePerProduct = {};
    final Map<int, Transaction> samplePerProduct = {};

    for (final t in todayTx) {
      totalSales += t.totalPrice;
      totalProfit += t.profit;
      qtyPerProduct[t.productId] = (qtyPerProduct[t.productId] ?? 0) + t.quantity;
      revenuePerProduct[t.productId] = (revenuePerProduct[t.productId] ?? 0) + t.totalPrice;
      samplePerProduct[t.productId] = t;
    }

    BestSeller? best;
    if (qtyPerProduct.isNotEmpty) {
      final sorted = qtyPerProduct.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final topId = sorted.first.key;
      final sample = samplePerProduct[topId]!;
      best = BestSeller(
        name: sample.productName,
        emoji: sample.productEmoji,
        qty: sorted.first.value,
        revenue: revenuePerProduct[topId]!,
      );
    }

    // Penjualan 7 hari terakhir.
    final weekly = <DailySales>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final next = day.add(const Duration(days: 1));
      final dayTx = transactions.items.where((t) => !t.dateTime.isBefore(day) && t.dateTime.isBefore(next));
      weekly.add(DailySales(
        date: day,
        total: dayTx.fold(0, (s, t) => s + t.totalPrice),
        count: dayTx.length,
      ));
    }

    _summary = DashboardSummary(
      totalSalesToday: totalSales,
      totalProfitToday: totalProfit,
      transactionCountToday: todayTx.length,
      bestSeller: best,
      lowStock: bahans.lowStock,
      totalBahan: bahans.items.length,
      weeklySales: weekly,
    );
    notifyListeners();
  }
}
