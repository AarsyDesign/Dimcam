enum ReportPeriod { daily, weekly, monthly, yearly }

class ReportData {
  ReportData({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalCost,
    required this.totalProfit,
    required this.transactionCount,
    required this.bestSellers,
    required this.dailyData,
  });

  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final int totalSales;
  final int totalCost;
  final int totalProfit;
  final int transactionCount;
  final List<BestSellerItem> bestSellers;
  final List<DailyReportData> dailyData;

  double get profitMargin => totalSales > 0 ? (totalProfit / totalSales) * 100 : 0;

  String get periodLabel {
    switch (period) {
      case ReportPeriod.daily:
        return 'Harian';
      case ReportPeriod.weekly:
        return 'Mingguan';
      case ReportPeriod.monthly:
        return 'Bulanan';
      case ReportPeriod.yearly:
        return 'Tahunan';
    }
  }
}

class BestSellerItem {
  BestSellerItem({
    required this.productId,
    required this.productName,
    required this.productEmoji,
    required this.quantity,
    required this.revenue,
    required this.profit,
  });

  final int productId;
  final String productName;
  final String productEmoji;
  final int quantity;
  final int revenue;
  final int profit;
}

class DailyReportData {
  DailyReportData({
    required this.date,
    required this.sales,
    required this.cost,
    required this.profit,
    required this.transactionCount,
  });

  final DateTime date;
  final int sales;
  final int cost;
  final int profit;
  final int transactionCount;
}
