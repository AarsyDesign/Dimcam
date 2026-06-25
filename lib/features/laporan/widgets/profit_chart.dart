import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/report.dart';

class ProfitChart extends StatelessWidget {
  const ProfitChart({super.key, required this.data});

  final List<DailyReportData> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Tidak ada data'));
    }

    final maxProfit = data.map((e) => e.profit).reduce((a, b) => a > b ? a : b);
    final minProfit = data.map((e) => e.profit).reduce((a, b) => a < b ? a : b);
    
    final bars = data.asMap().entries.map((entry) {
      final profit = entry.value.profit;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: profit.toDouble(),
            color: profit >= 0 ? AppColors.mintDeep : AppColors.coral,
            width: data.length > 20 ? 8 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        minY: minProfit < 0 ? minProfit * 1.2 : 0,
        maxY: maxProfit > 0 ? maxProfit * 1.2 : 100000,
        barGroups: bars,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                if (value == meta.max || value == meta.min) return const SizedBox.shrink();
                return Text(
                  _formatCurrency(value.toInt()),
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: data.length > 7 ? 2 : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _formatDate(data[index].date),
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxProfit > 0 ? maxProfit / 5 : 20000,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: AppColors.pinkSoft,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.pinkDeep,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final daily = data[groupIndex];
              return BarTooltipItem(
                '${DateFormat('d MMM', 'id_ID').format(daily.date)}\n${_formatCurrency(daily.profit)}',
                AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}rb';
    }
    return value.toString();
  }

  String _formatDate(DateTime date) {
    return DateFormat('d/M', 'id_ID').format(date);
  }
}
