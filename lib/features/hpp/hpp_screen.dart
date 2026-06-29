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
import '../../data/models/product.dart';
import '../../providers/bahan_provider.dart';
import '../../providers/hpp_provider.dart';
import '../../providers/product_provider.dart';

class HppScreen extends StatefulWidget {
  const HppScreen({super.key});

  @override
  State<HppScreen> createState() => _HppScreenState();
}

class _HppScreenState extends State<HppScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final products = context.read<ProductProvider>().items;
    await context.read<HppProvider>().loadAll(products.map((p) => p.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          const FeatureHeader(
            title: 'HPP Produk',
            subtitle: 'Harga Pokok Penjualan & margin',
            icon: Icons.calculate_rounded,
          ),
          Expanded(
            child: Consumer2<ProductProvider, HppProvider>(
              builder: (context, products, hpp, _) {
                if (products.loading || hpp.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.pinkAccent),
                  );
                }

                final items = products.items;
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inventory_2_rounded,
                    title: 'Belum ada produk',
                    subtitle: 'Tambahkan produk untuk melihat HPP',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.pinkAccent,
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(AppDimens.lg, 0, AppDimens.lg, AppDimens.xxxl),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final product = items[index];
                      return _HppCard(
                        product: product,
                        hpp: hpp,
                        products: products,
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
}

class _HppCard extends StatelessWidget {
  const _HppCard({
    required this.product,
    required this.hpp,
    required this.products,
  });

  final Product product;
  final HppProvider hpp;
  final ProductProvider products;

  @override
  Widget build(BuildContext context) {
    final hppValue = hpp.hppOf(product.id);
    final margin = product.sellingPrice - hppValue;
    final marginPercent = product.sellingPrice > 0
        ? (margin / product.sellingPrice) * 100
        : 0.0;
    final isProfitable = margin > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: AppCard(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            collapsedShape: const RoundedRectangleBorder(),
            shape: const RoundedRectangleBorder(),
            leading: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: AppColors.pinkGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(product.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(product.name, style: AppTextStyles.h3.copyWith(fontSize: 16)),
            subtitle: Text(product.category, style: AppTextStyles.caption),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Format.rupiah(margin),
                    style: AppTextStyles.bodyBold.copyWith(
                      color: isProfitable ? AppColors.mintDeep : AppColors.coral,
                      fontSize: 14,
                    )),
                Text(
                  '${marginPercent.toStringAsFixed(1)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: isProfitable ? AppColors.mintDeep : AppColors.coral,
                  ),
                ),
              ],
            ),
            children: [
              const Divider(height: AppDimens.lg),
              _HppDetails(
                product: product,
                hppValue: hppValue,
                margin: margin,
                isProfitable: isProfitable,
              ),
              const SizedBox(height: AppDimens.md),
              _ResepDetails(
                product: product,
                hpp: hpp,
              ),
              const SizedBox(height: AppDimens.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _HppDetails extends StatelessWidget {
  const _HppDetails({
    required this.product,
    required this.hppValue,
    required this.margin,
    required this.isProfitable,
  });

  final Product product;
  final int hppValue;
  final int margin;
  final bool isProfitable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.pinkSoft.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Harga Jual',
              value: Format.rupiah(product.sellingPrice),
              color: AppColors.pinkDeep,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.pinkSoft),
          Expanded(
            child: _StatItem(
              label: 'HPP',
              value: Format.rupiah(hppValue),
              color: AppColors.coral,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.pinkSoft),
          Expanded(
            child: _StatItem(
              label: 'Margin',
              value: Format.rupiah(margin),
              color: isProfitable ? AppColors.mintDeep : AppColors.coral,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.bodyBold.copyWith(color: color, fontSize: 13)),
      ],
    );
  }
}

class _ResepDetails extends StatelessWidget {
  const _ResepDetails({
    required this.product,
    required this.hpp,
  });

  final Product product;
  final HppProvider hpp;

  @override
  Widget build(BuildContext context) {
    final resep = hpp.resepOf(product.id);
    if (resep.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: AppColors.coral.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.coral.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.coral),
            const SizedBox(width: AppDimens.sm),
            Text('Belum ada resep', style: AppTextStyles.bodySmall.copyWith(color: AppColors.coral)),
          ],
        ),
      );
    }

    final bahans = context.watch<BahanProvider>().items;

    Bahan? bahanById(int id) {
      for (final b in bahans) {
        if (b.id == id) return b;
      }
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.restaurant_menu_rounded, size: 16, color: AppColors.textMuted),
            const SizedBox(width: AppDimens.xs),
            Text('Komposisi Bahan', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
            const Spacer(),
            KawaiiBadge(
              label: '${resep.length} bahan',
              variant: BadgeVariant.lavender,
              fontSize: 9,
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        ...resep.map((r) {
          final b = bahanById(r.bahanId);
          final subTotal = b != null ? (b.buyPrice * r.qtyUsed).round() : 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(b?.emoji ?? '📦', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: AppDimens.sm),
                Expanded(
                  child: Text(
                    b?.name ?? 'Bahan #${r.bahanId}',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                Text(
                  '${r.qtyUsed.toStringAsFixed(r.qtyUsed % 1 == 0 ? 0 : 1)} ${b?.unit ?? ''}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(width: AppDimens.sm),
                Text(
                  Format.rupiah(subTotal),
                  style: AppTextStyles.bodyBold.copyWith(fontSize: 12, color: AppColors.coral),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
