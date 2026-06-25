import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart' as fmt;
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/feature_header.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../data/models/bahan.dart';
import '../../providers/bahan_provider.dart';
import 'bahan_detail_screen.dart';
import 'purchase_form_screen.dart';
import 'production_form_screen.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({super.key});

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _filter = ['all', 'safe', 'low', 'out'][_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showActionMenu() {
    final bahanProvider = context.read<BahanProvider>();
    final rootNavigator = Navigator.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXxl)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.pinkSoft,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Text('Transaksi Stok', style: AppTextStyles.h3),
            const SizedBox(height: AppDimens.lg),
            _ActionTile(
              icon: Icons.shopping_cart_rounded,
              title: 'Pembelian Bahan',
              subtitle: 'Tambah stok dari pembelian',
              color: AppColors.pinkAccent,
              onTap: () {
                Navigator.pop(sheetContext);
                rootNavigator.push(
                  MaterialPageRoute(builder: (_) => const PurchaseFormScreen()),
                ).then((_) {
                  if (mounted) bahanProvider.refresh();
                });
              },
            ),
            const SizedBox(height: AppDimens.md),
            _ActionTile(
              icon: Icons.factory_rounded,
              title: 'Produksi',
              subtitle: 'Kurangi stok untuk produksi',
              color: AppColors.coral,
              onTap: () {
                Navigator.pop(sheetContext);
                rootNavigator.push(
                  MaterialPageRoute(builder: (_) => const ProductionFormScreen()),
                ).then((_) {
                  if (mounted) bahanProvider.refresh();
                });
              },
            ),
            const SizedBox(height: AppDimens.xxxl),
          ],
        ),
      ),
    );
  }

  void _viewDetail(Bahan bahan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BahanDetailScreen(bahan: bahan)),
    ).then((_) {
      if (mounted) {
        context.read<BahanProvider>().refresh();
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
            title: 'Stok Bahan',
            subtitle: 'Kelola stok bahan baku',
            icon: Icons.inventory_2_rounded,
            onAction: _showActionMenu,
          ),
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.pinkDeep,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.pinkAccent,
              labelStyle: AppTextStyles.bodyBold.copyWith(fontSize: 13),
              unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 13),
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Aman'),
                Tab(text: 'Menipis'),
                Tab(text: 'Habis'),
              ],
            ),
          ),
          Expanded(
            child: Consumer<BahanProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.pinkAccent),
                  );
                }

                final filtered = _filterBahans(provider.items);

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2_rounded,
                    title: 'Tidak ada bahan',
                    subtitle: _getEmptyMessage(),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.pinkAccent,
                  onRefresh: () => provider.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final bahan = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.md),
                        child: _BahanCard(
                          bahan: bahan,
                          onTap: () => _viewDetail(bahan),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Bahan> _filterBahans(List<Bahan> items) {
    return switch (_filter) {
      'safe' => items.where((b) => b.isSafe).toList(),
      'low' => items.where((b) => b.isLow).toList(),
      'out' => items.where((b) => b.isOut).toList(),
      _ => items,
    };
  }

  String _getEmptyMessage() {
    return switch (_filter) {
      'safe' => 'Tidak ada stok aman',
      'low' => 'Tidak ada stok menipis',
      'out' => 'Tidak ada stok habis',
      _ => 'Belum ada bahan terdaftar',
    };
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _BahanCard extends StatelessWidget {
  const _BahanCard({
    required this.bahan,
    required this.onTap,
  });

  final Bahan bahan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = bahan.status;
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);
    final double stockPercent = bahan.minStock > 0
        ? (bahan.stock / bahan.minStock).clamp(0.0, 1.0).toDouble()
        : 1.0;

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
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    bahan.emoji ?? '📦',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bahan.name, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      bahan.category,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${bahan.stock.toStringAsFixed(bahan.stock % 1 == 0 ? 0 : 1)} ${bahan.unit}',
                    style: AppTextStyles.h3.copyWith(color: statusColor, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fmt.Format.rupiah(bahan.buyPrice),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                            child: LinearProgressIndicator(
                              value: stockPercent.toDouble(),
                              backgroundColor: AppColors.pinkSoft,
                              color: statusColor,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        KawaiiBadge(
                          label: statusLabel,
                          variant: _getStatusBadge(status),
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Min. ${bahan.minStock.toStringAsFixed(0)} ${bahan.unit}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StockStatus status) {
    return switch (status) {
      StockStatus.safe => AppColors.mintDeep,
      StockStatus.low => AppColors.amber,
      StockStatus.out => AppColors.coral,
    };
  }

  String _getStatusLabel(StockStatus status) {
    return switch (status) {
      StockStatus.safe => 'Aman',
      StockStatus.low => 'Menipis',
      StockStatus.out => 'Habis',
    };
  }

  BadgeVariant _getStatusBadge(StockStatus status) {
    return switch (status) {
      StockStatus.safe => BadgeVariant.mint,
      StockStatus.low => BadgeVariant.amber,
      StockStatus.out => BadgeVariant.coral,
    };
  }
}

