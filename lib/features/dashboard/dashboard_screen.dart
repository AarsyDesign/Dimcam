import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/icon_bubble.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../core/widgets/common/section_title.dart';
import '../../core/widgets/common/stat_card.dart';
import '../../core/widgets/ornament/flower_decoration.dart';
import '../../core/widgets/ornament/sparkle_field.dart';
import '../../providers/dashboard_provider.dart';

/// 🏠 Halaman Dashboard — total penjualan, laba, transaksi, terlaris, ringkasan stok.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final summary = provider.summary;
        return RefreshIndicator(
          color: AppColors.pinkAccent,
          onRefresh: () async => provider.recompute(
            transactions: context.read(),
            stocks: context.read(),
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(summary: summary)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.lg, AppDimens.lg, AppDimens.xxxl),
                sliver: SliverList(
                  delegate: SliverChildList.fixed([
                    _StatsRow(summary: summary),
                    const SizedBox(height: AppDimens.xxl),
                    _BestSellerCard(summary: summary),
                    const SizedBox(height: AppDimens.xxl),
                    _StockSummaryCard(summary: summary),
                    const SizedBox(height: AppDimens.xxl),
                    _WeeklyMiniChart(summary: summary),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------- HEADER ----------------
class _Header extends StatelessWidget {
  const _Header({required this.summary});
  final DashboardSummary? summary;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat Pagi';
    if (h < 15) return 'Selamat Siang';
    if (h < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Positioned.fill(child: SparkleField(count: 14, color: AppColors.sparkleYellow)),
            Positioned(top: 18, right: 18, child: FlowerDecoration(size: 40, petalColor: AppColors.white.withValues(alpha: 0.85))),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.xl, AppDimens.xl, AppDimens.xl, AppDimens.xxxl),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.pinkDeep.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 38,
                        height: 38,
                        errorBuilder: (_, __, ___) => const Text('🥟', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(),
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withValues(alpha: 0.9))),
                        Text('Dimsumia Manager',
                            style: AppTextStyles.h2.copyWith(color: AppColors.white, fontSize: 20)),
                        const SizedBox(height: 2),
                        Text(today,
                            style: AppTextStyles.caption.copyWith(color: AppColors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                  Icon(Icons.notifications_active_rounded, color: AppColors.white.withValues(alpha: 0.9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- STATS ROW ----------------
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary});
  final DashboardSummary? summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Grid adaptif: 2 kolom utama + 1 di bawah, atau 3 kolom pada layar lebar.
        final wide = constraints.maxWidth > 380;
        final double gap = AppDimens.md;

        List<Widget> main = [
          Expanded(
            child: StatCard(
              icon: Icons.payments_rounded,
              label: 'Penjualan Hari Ini',
              value: s == null ? '—' : Format.rupiahShort(s.totalSalesToday),
              subtitle: 'Total omzet kotor',
              gradient: AppColors.headerGradient,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: StatCard(
              icon: Icons.savings_rounded,
              label: 'Laba Hari Ini',
              value: s == null ? '—' : Format.rupiahShort(s.totalProfitToday),
              subtitle: 'Setelah dikurangi HPP',
              gradient: const LinearGradient(colors: [AppColors.pinkAccent, AppColors.coral]),
              iconColor: AppColors.white,
            ),
          ),
        ];

        final transactionCard = StatCard(
          icon: Icons.receipt_long_rounded,
          label: 'Jumlah Transaksi',
          value: s == null ? '—' : Format.number(s.transactionCountToday),
          subtitle: 'Transaksi tercatat hari ini',
          gradient: const LinearGradient(colors: [AppColors.lavender, AppColors.pinkAccent]),
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...main,
              SizedBox(width: gap),
              Expanded(child: transactionCard),
            ],
          );
        }
        return Column(
          children: [
            SizedBox(height: 80, child: Row(children: main)),
            const SizedBox(height: gap),
            SizedBox(height: 80, child: transactionCard),
          ],
        );
      },
    );
  }
}

// ---------------- BEST SELLER ----------------
class _BestSellerCard extends StatelessWidget {
  const _BestSellerCard({required this.summary});
  final DashboardSummary? summary;

  @override
  Widget build(BuildContext context) {
    final best = summary?.bestSeller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Produk Terlaris Hari Ini',
          icon: Icons.emoji_events_rounded,
          actionLabel: 'Detail',
          onAction: () {},
        ),
        const SizedBox(height: AppDimens.md),
        if (best == null)
          const EmptyState(
            icon: Icons.sentiment_dissatisfied_rounded,
            title: 'Belum ada penjualan',
            subtitle: 'Produk terlaris akan muncul setelah ada transaksi.',
          )
        else
          AppCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.pinkLight, AppColors.ivory],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.pinkGradient,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.pinkDeep.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(child: Text(best.emoji, style: const TextStyle(fontSize: 32))),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const KawaiiBadge(label: '👑 Juara', variant: BadgeVariant.amber),
                          const SizedBox(width: AppDimens.xs),
                          Flexible(child: Text(best.name, style: AppTextStyles.h3, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${best.qty} terjual hari ini',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Format.rupiah(best.revenue),
                        style: AppTextStyles.h3.copyWith(color: AppColors.pinkDeep)),
                    Text('Omzet', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------- STOCK SUMMARY ----------------
class _StockSummaryCard extends StatelessWidget {
  const _StockSummaryCard({required this.summary});
  final DashboardSummary? summary;

  @override
  Widget build(BuildContext context) {
    final low = summary?.lowStock ?? [];
    final total = summary?.totalStockItems ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Ringkasan Stok',
          icon: Icons.inventory_2_rounded,
          actionLabel: low.isEmpty ? 'Aman' : '${low.length} menipis',
        ),
        const SizedBox(height: AppDimens.md),
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  const IconBubble(icon: Icons.verified_rounded, color: AppColors.mint, iconColor: AppColors.mintDeep),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$total item terdaftar', style: AppTextStyles.bodyBold),
                        Text(
                          low.isEmpty ? 'Semua stok aman 🌸' : 'Perlu restock segera',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: low.isEmpty ? AppColors.mintDeep : AppColors.coral,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (low.isEmpty)
                    const KawaiiBadge(label: '✓ Aman', variant: BadgeVariant.mint)
                  else
                    const KawaiiBadge(label: '⚠ Perhatian', variant: BadgeVariant.coral, icon: Icons.warning_amber_rounded),
                ],
              ),
              if (low.isNotEmpty) ...[
                const SizedBox(height: AppDimens.md),
                const Divider(),
                const SizedBox(height: AppDimens.sm),
                ...low.take(3).map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(s.emoji ?? '📦', style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(child: Text(s.name, style: AppTextStyles.body)),
                          KawaiiBadge(
                            label: s.isOut ? 'Habis' : 'Menipis',
                            variant: s.isOut ? BadgeVariant.coral : BadgeVariant.amber,
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Text('${s.quantity.toStringAsFixed(0)} ${s.unit}',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- WEEKLY MINI CHART ----------------
class _WeeklyMiniChart extends StatelessWidget {
  const _WeeklyMiniChart({required this.summary});
  final DashboardSummary? summary;

  @override
  Widget build(BuildContext context) {
    final weekly = summary?.weeklySales ?? const <DailySales>[];
    final maxVal = weekly.fold<int>(1, (m, d) => d.total > m ? d.total : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Tren 7 Hari', icon: Icons.trending_up_rounded),
        const SizedBox(height: AppDimens.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total minggu ini', style: AppTextStyles.caption),
                  Text(
                    Format.rupiah(weekly.fold(0, (s, d) => s + d.total)),
                    style: AppTextStyles.h3.copyWith(color: AppColors.pinkDeep, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.lg),
              SizedBox(
                height: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weekly.map((d) {
                    final isToday = d.date.day == DateTime.now().day &&
                        d.date.month == DateTime.now().month;
                    final h = (d.total / maxVal).clamp(0.05, 1.0);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                height: (h * 70),
                                decoration: BoxDecoration(
                                  gradient: isToday ? AppColors.pinkGradient : null,
                                  color: isToday ? null : AppColors.pinkSoft,
                                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('E', 'id_ID').format(d.date).substring(0, 1),
                              style: AppTextStyles.caption.copyWith(
                                color: isToday ? AppColors.pinkDeep : AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
