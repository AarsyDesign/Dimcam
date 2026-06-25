import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/icon_bubble.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/production.dart';
import '../../providers/production_provider.dart';

class ProductionDetailScreen extends StatefulWidget {
  const ProductionDetailScreen({super.key, required this.production});

  final Production production;

  @override
  State<ProductionDetailScreen> createState() => _ProductionDetailScreenState();
}

class _ProductionDetailScreenState extends State<ProductionDetailScreen> {
  List<ProductionDetail> _details = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _loading = true);
    final details = await DatabaseHelper.instance.getProductionDetails(widget.production.id);
    if (mounted) {
      setState(() {
        _details = details;
        _loading = false;
      });
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXl)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.coral),
            const SizedBox(width: AppDimens.sm),
            Text('Hapus Produksi?', style: AppTextStyles.h3),
          ],
        ),
        content: Text(
          'Data produksi ${widget.production.productName} akan dihapus permanen. Stok bahan tidak akan dikembalikan.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = context.read<ProductionProvider>();
              Navigator.pop(ctx);
              Navigator.pop(context);
              provider.remove(widget.production.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produksi berhasil dihapus')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final production = widget.production;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.coral,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detail Produksi', style: AppTextStyles.h3.copyWith(color: AppColors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.white),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.coral,
        onRefresh: _loadDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProductCard(production: production),
              const SizedBox(height: AppDimens.lg),
              _InfoCard(production: production),
              const SizedBox(height: AppDimens.lg),
              _MaterialsCard(details: _details, loading: _loading),
              const SizedBox(height: AppDimens.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.production});
  final Production production;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.pinkLight, AppColors.ivory],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.coral, Color(0xFFE8557E)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(production.productEmoji, style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Text(production.productName, style: AppTextStyles.h2),
          const SizedBox(height: AppDimens.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const KawaiiBadge(label: 'Produksi', variant: BadgeVariant.coral),
              const SizedBox(width: AppDimens.xs),
              KawaiiBadge(label: 'ID ${production.id}', variant: BadgeVariant.pink),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoItem(
                label: 'Jumlah',
                value: '${production.quantity}',
                subtitle: 'pcs',
              ),
              Container(width: 1, height: 40, color: AppColors.pinkSoft),
              _InfoItem(
                label: 'Biaya Bahan',
                value: Format.rupiahShort(production.totalCost),
                subtitle: 'total',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h3.copyWith(color: AppColors.coral)),
        Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.production});
  final Production production;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(
                icon: Icons.info_outline_rounded,
                color: AppColors.lavender,
                iconColor: AppColors.pinkDeep,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Informasi', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal',
            value: DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(production.dateTime),
          ),
          const SizedBox(height: AppDimens.md),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Waktu',
            value: DateFormat('HH:mm', 'id_ID').format(production.dateTime),
          ),
          if (production.note != null && production.note!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.md),
            _InfoRow(
              icon: Icons.note_rounded,
              label: 'Catatan',
              value: production.note!,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.coral),
        const SizedBox(width: AppDimens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyBold),
            ],
          ),
        ),
      ],
    );
  }
}

class _MaterialsCard extends StatelessWidget {
  const _MaterialsCard({
    required this.details,
    required this.loading,
  });

  final List<ProductionDetail> details;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(
                icon: Icons.restaurant_menu_rounded,
                color: AppColors.coral,
                iconColor: AppColors.white,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Bahan yang Digunakan', style: AppTextStyles.h3),
              const Spacer(),
              KawaiiBadge(
                label: '${details.length} bahan',
                variant: BadgeVariant.coral,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimens.xl),
                child: CircularProgressIndicator(color: AppColors.coral),
              ),
            )
          else if (details.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.xl),
                child: Text(
                  'Tidak ada detail bahan',
                  style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                ),
              ),
            )
          else
            Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: details.length,
                  separatorBuilder: (_, __) => const Divider(height: AppDimens.lg),
                  itemBuilder: (context, index) {
                    final detail = details[index];
                    return _MaterialItem(detail: detail);
                  },
                ),
                const SizedBox(height: AppDimens.md),
                const Divider(),
                const SizedBox(height: AppDimens.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Biaya Bahan', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                    Text(
                      Format.rupiah(details.fold(0, (sum, d) => sum + d.cost)),
                      style: AppTextStyles.h3.copyWith(color: AppColors.coral, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MaterialItem extends StatelessWidget {
  const _MaterialItem({required this.detail});
  final ProductionDetail detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(detail.bahanEmoji ?? '📦', style: const TextStyle(fontSize: 20)),
        const SizedBox(width: AppDimens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.bahanName, style: AppTextStyles.bodyBold),
              Text(
                '${detail.qtyUsed.toStringAsFixed(detail.qtyUsed % 1 == 0 ? 0 : 1)} ${detail.unit}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Format.rupiah(detail.cost),
              style: AppTextStyles.bodyBold.copyWith(color: AppColors.coral),
            ),
            Text('biaya', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}

