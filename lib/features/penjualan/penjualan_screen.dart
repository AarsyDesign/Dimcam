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
import '../../data/models/transaction.dart';
import '../../providers/transaction_provider.dart';
import 'transaction_detail_screen.dart';
import 'transaction_form_screen.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({super.key});

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<TransactionProvider>().setQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<TransactionProvider>().clearQuery();
  }

  void _addTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
    ).then((_) {
      if (mounted) {
        context.read<TransactionProvider>().refresh();
      }
    });
  }

  void _viewDetail(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TransactionDetailScreen(transaction: transaction)),
    ).then((_) {
      if (mounted) {
        context.read<TransactionProvider>().refresh();
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
            title: 'Penjualan',
            subtitle: 'Kelola transaksi penjualan',
            icon: Icons.sell_rounded,
            onAction: _addTransaction,
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: _SearchBar(
              controller: _searchController,
              onChanged: _onSearch,
              onClear: _clearSearch,
            ),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.pinkAccent),
                  );
                }

                if (provider.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: provider.query.isEmpty ? 'Belum ada transaksi' : 'Transaksi tidak ditemukan',
                    subtitle: provider.query.isEmpty
                        ? 'Mulai catat penjualan dengan tap tombol +'
                        : 'Coba kata kunci lain',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.pinkAccent,
                  onRefresh: () => provider.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(AppDimens.lg, 0, AppDimens.lg, AppDimens.xxxl),
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final tx = provider.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.md),
                        child: _TransactionCard(
                          transaction: tx,
                          onTap: () => _viewDetail(tx),
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
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari produk atau catatan...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.onTap,
  });

  final Transaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(transaction.dateTime);
    final profit = transaction.profit;
    final profitPositive = profit >= 0;

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
                  gradient: AppColors.pinkGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    transaction.productEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.productName, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      '${transaction.quantity} × ${Format.rupiah(transaction.unitPrice)}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Format.rupiah(transaction.totalPrice),
                    style: AppTextStyles.h3.copyWith(color: AppColors.pinkDeep, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        profitPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 14,
                        color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        Format.rupiah(profit.abs()),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                DateFormat('EEEE, d MMM yyyy · HH:mm', 'id_ID').format(transaction.dateTime),
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              if (isToday) const KawaiiBadge(label: 'Hari ini', variant: BadgeVariant.pink),
            ],
          ),
          if (transaction.note != null && transaction.note!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.sm),
            Row(
              children: [
                const Icon(Icons.note_rounded, size: 14, color: AppColors.pinkAccent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    transaction.note!,
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
