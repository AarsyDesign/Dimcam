import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/feature_header.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../data/models/bahan.dart';
import '../../providers/bahan_provider.dart';
import '../../features/laporan/pdf_export_service.dart';
import 'bahan_detail_screen.dart';
import 'purchase_form_screen.dart';
import '../produksi/production_form_screen.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({super.key});

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _filter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

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

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXxl)),
      ),
      builder: (context) => Padding(
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
              onTap: () async {
                final bahanProvider = context.read<BahanProvider>();
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PurchaseFormScreen()),
                );
                if (!mounted) return;
                bahanProvider.refresh();
              },
            ),
            const SizedBox(height: AppDimens.md),
            _ActionTile(
              icon: Icons.factory_rounded,
              title: 'Produksi',
              subtitle: 'Kurangi stok untuk produksi',
              color: AppColors.coral,
              onTap: () async {
                final bahanProvider = context.read<BahanProvider>();
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductionFormScreen()),
                );
                if (!mounted) return;
                bahanProvider.refresh();
              },
            ),
            const SizedBox(height: AppDimens.md),
            _ActionTile(
              icon: Icons.picture_as_pdf_rounded,
              title: 'Export PDF',
              subtitle: 'Cetak laporan stok',
              color: AppColors.pinkDeep,
              onTap: () async {
                Navigator.pop(context);
                await PdfExportService.generateStokPdf();
              },
            ),
            const SizedBox(height: AppDimens.xxxl),
          ],
        ),
      ),
    );
  }

  void _viewDetail(Bahan bahan) {
    final bahanProvider = context.read<BahanProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BahanDetailScreen(bahan: bahan)),
    ).then((_) {
      if (mounted) {
        bahanProvider.refresh();
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
          _SearchBar(
            controller: _searchController,
            provider: context.read<BahanProvider>(),
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

                final searched = _searchController.text.isNotEmpty
                    ? provider.filteredItems
                    : provider.items;
                final filtered = _filterBahans(searched);

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

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.controller, required this.provider});
  final TextEditingController controller;
  final BahanProvider provider;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.md, AppDimens.lg, 0),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: 'Cari bahan...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    widget.controller.clear();
                    widget.provider.setSearchQuery('');
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (value) {
          widget.provider.setSearchQuery(value);
          setState(() {});
        },
      ),
    );
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
    final double stockPercent =
    bahan.minStock > 0
        ? (bahan.stock / bahan.minStock)
              .clamp(0.0, 1.0)
              .toDouble()
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
                    Format.rupiah(bahan.buyPrice),
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
