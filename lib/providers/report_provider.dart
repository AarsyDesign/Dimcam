import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/report.dart';
import '../data/models/transaction.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider() {
    _generateReport();
  }

  final DatabaseHelper _db = DatabaseHelper.instance;

  ReportPeriod _period = ReportPeriod.daily;
  ReportPeriod get period => _period;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  ReportData? _reportData;
  ReportData? get reportData => _reportData;

  bool _loading = true;
  bool get loading => _loading;

  void setPeriod(ReportPeriod period) {
    _period = period;
    _generateReport();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    _generateReport();
  }

  void nextPeriod() {
    switch (_period) {
      case ReportPeriod.daily:
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        break;
      case ReportPeriod.weekly:
        _selectedDate = _selectedDate.add(const Duration(days: 7));
        break;
      case ReportPeriod.monthly:
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
        break;
      case ReportPeriod.yearly:
        _selectedDate = DateTime(_selectedDate.year + 1, 1, 1);
        break;
    }
    _generateReport();
  }

  void previousPeriod() {
    switch (_period) {
      case ReportPeriod.daily:
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
        break;
      case ReportPeriod.weekly:
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.monthly:
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
        break;
      case ReportPeriod.yearly:
        _selectedDate = DateTime(_selectedDate.year - 1, 1, 1);
        break;
    }
    _generateReport();
  }

  Future<void> _generateReport() async {
    _loading = true;
    notifyListeners();

    final dateRange = _getDateRange();
    final startDate = dateRange.$1;
    final endDate = dateRange.$2;

    final allTx = await _db.getTransactions();
    final List<Transaction> filtered = [];
    for (final t in allTx) {
      if (!t.dateTime.isBefore(startDate) && t.dateTime.isBefore(endDate)) {
        filtered.add(t);
      }
    }

    int totalSales = 0;
    int totalCost = 0;
    int totalProfit = 0;
    final Map<int, BestSellerItem> productMap = {};

    for (final t in filtered) {
      totalSales += t.totalPrice;
      totalCost += t.totalCost;
      totalProfit += t.profit;

      if (productMap.containsKey(t.productId)) {
        final existing = productMap[t.productId]!;
        productMap[t.productId] = BestSellerItem(
          productId: existing.productId,
          productName: existing.productName,
          productEmoji: existing.productEmoji,
          quantity: existing.quantity + t.quantity,
          revenue: existing.revenue + t.totalPrice,
          profit: existing.profit + t.profit,
        );
      } else {
        productMap[t.productId] = BestSellerItem(
          productId: t.productId,
          productName: t.productName,
          productEmoji: t.productEmoji,
          quantity: t.quantity,
          revenue: t.totalPrice,
          profit: t.profit,
        );
      }
    }

    final bestSellers = productMap.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    final dailyData = _generateDailyData(filtered, startDate, endDate);

    _reportData = ReportData(
      period: _period,
      startDate: startDate,
      endDate: endDate,
      totalSales: totalSales,
      totalCost: totalCost,
      totalProfit: totalProfit,
      transactionCount: filtered.length,
      bestSellers: bestSellers.take(5).toList(),
      dailyData: dailyData,
    );

    _loading = false;
    notifyListeners();
  }

  (DateTime, DateTime) _getDateRange() {
    switch (_period) {
      case ReportPeriod.daily:
        final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        final end = start.add(const Duration(days: 1));
        return (start, end);

      case ReportPeriod.weekly:
        final weekday = _selectedDate.weekday;
        final start = _selectedDate.subtract(Duration(days: weekday - 1));
        final startOfWeek = DateTime(start.year, start.month, start.day);
        final end = startOfWeek.add(const Duration(days: 7));
        return (startOfWeek, end);

      case ReportPeriod.monthly:
        final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
        final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
        return (start, end);

      case ReportPeriod.yearly:
        final start = DateTime(_selectedDate.year, 1, 1);
        final end = DateTime(_selectedDate.year + 1, 1, 1);
        return (start, end);
    }
  }

  List<DailyReportData> _generateDailyData(List<Transaction> transactions, DateTime start, DateTime end) {
    final dailyMap = <String, DailyReportData>{};

    DateTime current = start;
    while (current.isBefore(end)) {
      final key = _dateKey(current);
      dailyMap[key] = DailyReportData(
        date: current,
        sales: 0,
        cost: 0,
        profit: 0,
        transactionCount: 0,
      );
      current = current.add(const Duration(days: 1));
    }

    for (final t in transactions) {
      final key = _dateKey(t.dateTime);
      if (dailyMap.containsKey(key)) {
        final existing = dailyMap[key]!;
        dailyMap[key] = DailyReportData(
          date: existing.date,
          sales: existing.sales + t.totalPrice,
          cost: existing.cost + t.totalCost,
          profit: existing.profit + t.profit,
          transactionCount: existing.transactionCount + 1,
        );
      }
    }

    final result = dailyMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  Future<void> refresh() async {
    await _generateReport();
  }
}
