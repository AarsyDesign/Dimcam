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
import '../../data/database/database_helper.dart';
import '../../data/models/bahan.dart';
import '../../data/models/stock_transaction.dart';
import '../../providers/bahan_provider.dart';
import 'adjustment_form_screen.dart';

class BahanDetailScreen extends StatefulWidget {
  const BahanDetailScreen({super.key, required this.bahan});

  final Bahan bahan;

  @override
  State<BahanDetailScreen> createState() => _BahanDetailScreenState();
}

class _BahanDetailScreenState extends State<BahanDetailScreen> {
  List<StockTransaction> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final history = await DatabaseHelper.instance.getStockTransactions(bahanId: widget.bahan.id);
    if (mounted) {
      setState(() {
        _history = history;
        _loading = false;
      });
    }
  }

  void _showAdjustment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdjustmentFormScreen(bahan: widget.bahan),
      ),
    ).then((_) {
      if (mounted) {
        context.read<BahanProvider>().refresh();
        _loadHistory();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bahan = widget.bahan;
    final status = bahan.status;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.pinkAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detail Stok', style: AppTextStyles.h3.copyWith(color: AppColors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.white),
            onPressed: _showAdjustment,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.pinkAccent,
        onRefresh: () async {
          await context.read<BahanProvider>().refresh();
          await _loadHistory();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoCard(bahan: bahan),
              const SizedBox(height: AppDimens.lg),
              _StockCard(bahan: bahan, status: status),
              const SizedBox(height: AppDimens.lg),
              _HistoryCard(history: _history, loading: _loading),
              const SizedBox(height: AppDimens.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.bahan});
  final Bahan bahan;

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
              gradient: AppColors.pinkGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pinkDeep.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(bahan.emoji ?? '📦', style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Text(bahan.name, style: AppTextStyles.h2),
          const SizedBox(height: AppDimens.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KawaiiBadge(label: bahan.category, variant: BadgeVariant.lavender),
              const SizedBox(width: AppDimens.xs),
              KawaiiBadge(label: 'ID ${bahan.id}', variant: BadgeVariant.pink),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoItem(
                label: 'Harga Beli',
                value: Format.rupiah(bahan.buyPrice),
                subtitle: 'per ${bahan.unit}',
              ),
              Container(width: 1, height: 40, color: AppColors.pinkSoft),
              _InfoItem(
                label: 'Satuan',
                value: bahan.unit,
                subtitle: 'unit',
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
        Text(value, style: AppTextStyles.h3.copyWith(color: AppColors.pinkDeep)),
        Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.bahan, required this.status});
  final Bahan bahan;
  final StockStatus status;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);
    final double stockPercent = bahan.minStock > 0 ? (bahan.stock / bahan.minStock).clamp(0.0, 1.5).toDouble() : 1.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
            IconBubble(
              icon: Icons.inventory_rounded,
              color: statusColor.withValues(alpha: 0.15),
              iconColor: statusColor,
            ),
              const SizedBox(width: AppDimens.sm),
              Text('Status Stok', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stok Tersedia', style: AppTextStyles.body),
              Text(
                '${bahan.stock.toStringAsFixed(bahan.stock % 1 == 0 ? 0 : 1)} ${bahan.unit}',
                style: AppTextStyles.h2.copyWith(color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: LinearProgressIndicator(
              value: stockPercent.toDouble(),
              backgroundColor: AppColors.pinkSoft,
              color: statusColor,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Batas Minimum: ${bahan.minStock.toStringAsFixed(0)} ${bahan.unit}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              KawaiiBadge(
                label: statusLabel,
                variant: _getStatusBadge(status),
                icon: _getStatusIcon(status),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          if (status != StockStatus.safe)
            Container(
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: statusColor, size: 20),
                  const SizedBox(width: AppDimens.sm),
                  Expanded(
                    child: Text(
                      status == StockStatus.out
                          ? 'Stok habis! Segera lakukan pembelian.'
                          : 'Stok menipis, pertimbangkan untuk melakukan pembelian.',
                      style: AppTextStyles.bodySmall.copyWith(color: statusColor),
                    ),
                  ),
                ],
              ),
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

  IconData _getStatusIcon(StockStatus status) {
    return switch (status) {
      StockStatus.safe => Icons.check_circle_rounded,
      StockStatus.low => Icons.warning_rounded,
      StockStatus.out => Icons.cancel_rounded,
    };
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.history, required this.loading});
  final List<StockTransaction> history;
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
                icon: Icons.history_rounded,
                color: AppColors.lavender,
                iconColor: AppColors.pinkDeep,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Histori Perubahan', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimens.xl),
                child: CircularProgressIndicator(color: AppColors.pinkAccent),
              ),
            )
          else if (history.isEmpty)
            const EmptyState(
              icon: Icons.history_rounded,
              title: 'Belum ada histori',
              subtitle: 'Perubahan stok akan muncul di sini',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(height: AppDimens.lg),
              itemBuilder: (context, index) {
                final tx = history[index];
                return _HistoryItem(transaction: tx);
              },
            ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.transaction});
  final StockTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isInbound = transaction.isInbound;
    final color = isInbound ? AppColors.mintDeep : AppColors.coral;
    final icon = isInbound ? Icons.add_circle_rounded : Icons.remove_circle_rounded;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(transaction.typeLabel, style: AppTextStyles.bodyBold),
                  Text(
                    '${isInbound ? '+' : ''}${transaction.quantity.toStringAsFixed(transaction.quantity % 1 == 0 ? 0 : 1)}',
                    style: AppTextStyles.h3.copyWith(color: color, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('d MMM yyyy · HH:mm', 'id_ID').format(transaction.dateTime),
                style: AppTextStyles.caption,
              ),
              if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  transaction.note!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (transaction.productName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.factory_rounded, size: 14, color: AppColors.pinkAccent),
                    const SizedBox(width: 4),
                    Text(
                      transaction.productName!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.pinkDeep),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
