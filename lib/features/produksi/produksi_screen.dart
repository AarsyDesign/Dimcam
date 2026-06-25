import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/feature_header.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../data/models/production.dart';
import '../../providers/production_provider.dart';
import 'production_detail_screen.dart';
import 'production_form_screen.dart';

class ProduksiScreen extends StatefulWidget {
  const ProduksiScreen({super.key});

  @override
  State<ProduksiScreen> createState() => _ProduksiScreenState();
}

class _ProduksiScreenState extends State<ProduksiScreen> {
  void _addProduction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductionFormScreen()),
    ).then((_) {
      if (mounted) {
        context.read<ProductionProvider>().refresh();
      }
    });
  }

  void _viewDetail(Production production) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductionDetailScreen(production: production)),
    ).then((_) {
      if (mounted) {
        context.read<ProductionProvider>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          FeatureHeader(
            title: 'Produksi',
            subtitle: 'Riwayat produksi produk',
            icon: Icons.factory_rounded,
            onAction: _addProduction,
          ),
          Expanded(
            child: Consumer<ProductionProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.pinkAccent),
                  );
                }

                if (provider.items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.factory_rounded,
                    title: 'Belum ada produksi',
                    subtitle: 'Mulai produksi dengan tap tombol +',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.pinkAccent,
                  onRefresh: () => provider.refresh(),
                  child: Column(
                    children: [
                      _SummaryCard(provider: provider),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(AppDimens.lg, 0, AppDimens.lg, AppDimens.xxxl),
                          itemCount: provider.items.length,
                          itemBuilder: (context, index) {
                            final production = provider.items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppDimens.md),
                              child: _ProductionCard(
                                production: production,
                                onTap: () => _viewDetail(production),
                              ),
                            );
                          },
                        ),
                      ),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.provider});
  final ProductionProvider provider;

  @override
  Widget build(BuildContext context) {
    final today = provider.today;
    final totalQty = provider.totalProductionToday;
    final totalCost = provider.totalCostToday;

    if (today.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(AppDimens.lg),
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pinkLight, AppColors.ivory],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: AppColors.pinkSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today_rounded, color: AppColors.pinkDeep, size: 20),
              const SizedBox(width: AppDimens.xs),
              Text('Produksi Hari Ini', style: AppTextStyles.h3.copyWith(fontSize: 15)),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.inventory_rounded,
                  label: 'Total Produksi',
                  value: '$totalQty pcs',
                  color: AppColors.pinkAccent,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.pinkSoft),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.payments_rounded,
                  label: 'Total Biaya',
                  value: Format.rupiahShort(totalCost),
                  color: AppColors.coral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
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
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppDimens.xs),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        Text(value, style: AppTextStyles.h3.copyWith(color: color, fontSize: 16)),
      ],
    );
  }
}

class _ProductionCard extends StatelessWidget {
  const _ProductionCard({
    required this.production,
    required this.onTap,
  });

  final Production production;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(production.dateTime);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.coral, Color(0xFFE8557E)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    production.productEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(production.productName, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      '${production.quantity} pcs diproduksi',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Format.rupiah(production.totalCost),
                    style: AppTextStyles.h3.copyWith(color: AppColors.coral, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Biaya Bahan',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(height: 1),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                DateFormat('EEEE, d MMM yyyy · HH:mm', 'id_ID').format(production.dateTime),
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              if (isToday) const KawaiiBadge(label: 'Hari ini', variant: BadgeVariant.pink),
            ],
          ),
          if (production.note != null && production.note!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.sm),
            Row(
              children: [
                const Icon(Icons.note_rounded, size: 14, color: AppColors.pinkAccent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    production.note!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.pinkDeep,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
