import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/icon_bubble.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../data/models/transaction.dart';
import '../../providers/transaction_provider.dart';
import 'transaction_form_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.pinkAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detail Transaksi', style: AppTextStyles.h3.copyWith(color: AppColors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.white),
            onPressed: () => _editTransaction(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.white),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductCard(transaction: transaction),
            const SizedBox(height: AppDimens.lg),
            _CalculationCard(transaction: transaction),
            const SizedBox(height: AppDimens.lg),
            _InfoCard(transaction: transaction),
            const SizedBox(height: AppDimens.xxxl),
          ],
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context) {
    final navigator = Navigator.of(context);
    final route = MaterialPageRoute(
      builder: (_) => TransactionFormScreen(transaction: transaction),
    );
    navigator.push(route).then((updated) {
      if (updated == true) {
        navigator.pop();
      }
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXl)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.coral),
            const SizedBox(width: AppDimens.sm),
            Text('Hapus Transaksi?', style: AppTextStyles.h3),
          ],
        ),
        content: Text(
          'Transaksi ${transaction.productName} akan dihapus permanen.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = context.read<TransactionProvider>();
              Navigator.pop(ctx);
              Navigator.pop(context);
              provider.remove(transaction.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil dihapus')),
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
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.transaction});
  final Transaction transaction;

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
              child: Text(transaction.productEmoji, style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Text(transaction.productName, style: AppTextStyles.h2),
          const SizedBox(height: AppDimens.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const KawaiiBadge(label: 'ID', variant: BadgeVariant.pink),
              const SizedBox(width: AppDimens.xs),
              Text('#${transaction.id}', style: AppTextStyles.bodyBold),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalculationCard extends StatelessWidget {
  const _CalculationCard({required this.transaction});
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final profit = transaction.profit;
    final profitPositive = profit >= 0;
    final marginPercent = transaction.unitPrice > 0
        ? ((profit / transaction.totalPrice) * 100)
        : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(
                icon: Icons.calculate_rounded,
                color: AppColors.pinkSoft,
                iconColor: AppColors.pinkDeep,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Rincian Biaya', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          _DetailRow(
            label: 'Harga Satuan',
            value: Format.rupiah(transaction.unitPrice),
          ),
          const SizedBox(height: AppDimens.sm),
          _DetailRow(
            label: 'Jumlah',
            value: '${transaction.quantity} pcs',
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(),
          const SizedBox(height: AppDimens.sm),
          _DetailRow(
            label: 'Total Penjualan',
            value: Format.rupiah(transaction.totalPrice),
            bold: true,
          ),
          const SizedBox(height: AppDimens.sm),
          _DetailRow(
            label: 'HPP per Unit',
            value: Format.rupiah(transaction.hppPerUnit),
            valueColor: AppColors.textMuted,
          ),
          const SizedBox(height: AppDimens.sm),
          _DetailRow(
            label: 'Total HPP',
            value: Format.rupiah(transaction.totalCost),
            valueColor: AppColors.textMuted,
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              Expanded(
                child: Text('Laba Bersih', style: AppTextStyles.h3.copyWith(fontSize: 16)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        profitPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 18,
                        color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Format.rupiah(profit.abs()),
                        style: AppTextStyles.h3.copyWith(
                          color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Margin ${marginPercent.toStringAsFixed(1)}%',
                    style: AppTextStyles.caption.copyWith(
                      color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                    ),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.transaction});
  final Transaction transaction;

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
            value: Format.dateLong(transaction.dateTime),
          ),
          const SizedBox(height: AppDimens.md),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Waktu',
            value: '${transaction.dateTime.hour.toString().padLeft(2, '0')}:${transaction.dateTime.minute.toString().padLeft(2, '0')}',
          ),
          if (transaction.note != null && transaction.note!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.md),
            _InfoRow(
              icon: Icons.note_rounded,
              label: 'Catatan',
              value: transaction.note!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold ? AppTextStyles.bodyBold : AppTextStyles.body,
        ),
        Text(
          value,
          style: (bold ? AppTextStyles.bodyBold : AppTextStyles.body).copyWith(
            color: valueColor,
          ),
        ),
      ],
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
        Icon(icon, size: 18, color: AppColors.pinkAccent),
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
