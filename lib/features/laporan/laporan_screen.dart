import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/feature_header.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../data/models/report.dart';
import '../../providers/report_provider.dart';
import 'widgets/best_seller_chart.dart';
import 'widgets/profit_chart.dart';
import 'widgets/sales_chart.dart';
import 'pdf_export_service.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  bool _exportingPdf = false;

  void _exportPdf() async {
    final reportData = context.read<ReportProvider>().reportData;
    if (reportData == null) return;

    setState(() => _exportingPdf = true);

    try {
      await PdfExportService.generateAndShareReport(reportData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF berhasil dibuat')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _exportingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          FeatureHeader(
            title: 'Laporan',
            subtitle: 'Analisis keuangan & penjualan',
            icon: Icons.bar_chart_rounded,
            onAction: _exportingPdf ? null : _exportPdf,
            actionIcon: Icons.picture_as_pdf_rounded,
          ),
          Expanded(
            child: Consumer<ReportProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.pinkAccent),
                  );
                }

                final report = provider.reportData;
                if (report == null) {
                  return const Center(
                    child: Text('Tidak ada data'),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.pinkAccent,
                  onRefresh: () => provider.refresh(),
                  child: ListView(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    children: [
                      _PeriodSelector(provider: provider),
                      const SizedBox(height: AppDimens.lg),
                      _DateNavigator(provider: provider),
                      const SizedBox(height: AppDimens.lg),
                      _SummaryCards(report: report),
                      const SizedBox(height: AppDimens.lg),
                      _SalesChart(report: report),
                      const SizedBox(height: AppDimens.lg),
                      _ProfitChart(report: report),
                      const SizedBox(height: AppDimens.lg),
                      _BestSellerChart(report: report),
                      const SizedBox(height: AppDimens.xxxl),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.provider});
  final ReportProvider provider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PeriodButton(
            label: 'Harian',
            selected: provider.period == ReportPeriod.daily,
            onTap: () => provider.setPeriod(ReportPeriod.daily),
          ),
        ),
        const SizedBox(width: AppDimens.xs),
        Expanded(
          child: _PeriodButton(
            label: 'Mingguan',
            selected: provider.period == ReportPeriod.weekly,
            onTap: () => provider.setPeriod(ReportPeriod.weekly),
          ),
        ),
        const SizedBox(width: AppDimens.xs),
        Expanded(
          child: _PeriodButton(
            label: 'Bulanan',
            selected: provider.period == ReportPeriod.monthly,
            onTap: () => provider.setPeriod(ReportPeriod.monthly),
          ),
        ),
        const SizedBox(width: AppDimens.xs),
        Expanded(
          child: _PeriodButton(
            label: 'Tahunan',
            selected: provider.period == ReportPeriod.yearly,
            onTap: () => provider.setPeriod(ReportPeriod.yearly),
          ),
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.pinkAccent : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: Border.all(
            color: selected ? AppColors.pinkAccent : AppColors.pinkSoft,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? AppColors.white : AppColors.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({required this.provider});
  final ReportProvider provider;

  String _getDateLabel() {
    final date = provider.selectedDate;
    switch (provider.period) {
      case ReportPeriod.daily:
        return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
      case ReportPeriod.weekly:
        final weekday = date.weekday;
        final start = date.subtract(Duration(days: weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('d MMM', 'id_ID').format(start)} - ${DateFormat('d MMM yyyy', 'id_ID').format(end)}';
      case ReportPeriod.monthly:
        return DateFormat('MMMM yyyy', 'id_ID').format(date);
      case ReportPeriod.yearly:
        return DateFormat('yyyy', 'id_ID').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: provider.previousPeriod,
            color: AppColors.pinkDeep,
          ),
          Expanded(
            child: Text(
              _getDateLabel(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyBold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: provider.nextPeriod,
            color: AppColors.pinkDeep,
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.report});
  final ReportData report;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.payments_rounded,
                label: 'Omset',
                value: Format.rupiahShort(report.totalSales),
                color: AppColors.pinkAccent,
              ),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: _SummaryCard(
                icon: Icons.receipt_long_rounded,
                label: 'HPP',
                value: Format.rupiahShort(report.totalCost),
                color: AppColors.coral,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.md),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.savings_rounded,
                label: 'Laba Bersih',
                value: Format.rupiahShort(report.totalProfit),
                color: AppColors.mintDeep,
              ),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: _SummaryCard(
                icon: Icons.shopping_cart_rounded,
                label: 'Transaksi',
                value: '${report.transactionCount}',
                color: AppColors.lavender,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.md),
        AppCard(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.pinkLight, AppColors.ivory],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up_rounded, color: AppColors.pinkDeep),
                  const SizedBox(width: AppDimens.sm),
                  Text('Margin Keuntungan', style: AppTextStyles.h3.copyWith(fontSize: 15)),
                ],
              ),
              Text(
                '${report.profitMargin.toStringAsFixed(1)}%',
                style: AppTextStyles.h2.copyWith(color: AppColors.pinkDeep, fontSize: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppDimens.xs),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: color, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.report});
  final ReportData report;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, color: AppColors.pinkAccent),
              const SizedBox(width: AppDimens.sm),
              Text('Grafik Penjualan', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          SizedBox(
            height: 200,
            child: SalesChart(data: report.dailyData),
          ),
        ],
      ),
    );
  }
}

class _ProfitChart extends StatelessWidget {
  const _ProfitChart({required this.report});
  final ReportData report;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: AppColors.mintDeep),
              const SizedBox(width: AppDimens.sm),
              Text('Grafik Laba', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          SizedBox(
            height: 200,
            child: ProfitChart(data: report.dailyData),
          ),
        ],
      ),
    );
  }
}

class _BestSellerChart extends StatelessWidget {
  const _BestSellerChart({required this.report});
  final ReportData report;

  @override
  Widget build(BuildContext context) {
    if (report.bestSellers.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.amber),
              const SizedBox(width: AppDimens.sm),
              Text('Produk Terlaris', style: AppTextStyles.h3),
              const Spacer(),
              KawaiiBadge(
                label: 'Top ${report.bestSellers.length}',
                variant: BadgeVariant.amber,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          SizedBox(
            height: 250,
            child: BestSellerChart(items: report.bestSellers),
          ),
        ],
      ),
    );
  }
}

