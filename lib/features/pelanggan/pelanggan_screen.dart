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
import '../../data/models/customer.dart';
import '../../providers/customer_provider.dart';
import 'customer_detail_screen.dart';
import 'customer_form_screen.dart';

class PelangganScreen extends StatefulWidget {
  const PelangganScreen({super.key});

  @override
  State<PelangganScreen> createState() => _PelangganScreenState();
}

class _PelangganScreenState extends State<PelangganScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
    ).then((_) {
      if (mounted) context.read<CustomerProvider>().refresh();
    });
  }

  void _viewDetail(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: customer)),
    ).then((_) {
      if (mounted) context.read<CustomerProvider>().refresh();
    });
  }

  void _editCustomer(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer)),
    ).then((_) {
      if (mounted) context.read<CustomerProvider>().refresh();
    });
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final provider = context.read<CustomerProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXl)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.coral),
            const SizedBox(width: AppDimens.sm),
            Text('Hapus Pelanggan?', style: AppTextStyles.h3),
          ],
        ),
        content: Text(
          '${customer.name} akan dihapus permanen. Riwayat transaksi tetap tersimpan.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.remove(customer.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pelanggan berhasil dihapus')),
        );
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
            title: 'Pelanggan',
            subtitle: 'Data & ranking pelanggan',
            icon: Icons.people_rounded,
            onAction: _addCustomer,
          ),
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.pinkAccent),
                  );
                }

                final items = provider.rankedItems;

                return RefreshIndicator(
                  color: AppColors.pinkAccent,
                  onRefresh: () => provider.refresh(),
                  child: Column(
                    children: [
                      _SearchBar(
                        controller: _searchController,
                        provider: provider,
                      ),
                      if (items.isNotEmpty)
                        _RankSummary(items: items),
                      Expanded(
                        child: items.isEmpty
                            ? const EmptyState(
                                icon: Icons.people_rounded,
                                title: 'Belum ada pelanggan',
                                subtitle: 'Tambahkan pelanggan dengan tap tombol +',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    AppDimens.lg, 0, AppDimens.lg, AppDimens.xxxl),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final customer = items[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppDimens.md),
                                    child: _CustomerCard(
                                      rank: index + 1,
                                      customer: customer,
                                      onTap: () => _viewDetail(customer),
                                      onEdit: () => _editCustomer(customer),
                                      onDelete: () => _deleteCustomer(customer),
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

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.controller, required this.provider});
  final TextEditingController controller;
  final CustomerProvider provider;

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
          hintText: 'Cari pelanggan...',
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

class _RankSummary extends StatelessWidget {
  const _RankSummary({required this.items});
  final List<Customer> items;

  @override
  Widget build(BuildContext context) {
    final totalCustomer = items.length;
    final totalRevenue = items.fold<int>(0, (s, c) => s + c.totalPurchase);
    final avgPerCustomer = totalCustomer > 0 ? totalRevenue ~/ totalCustomer : 0;

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
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.people_rounded,
              label: 'Pelanggan',
              value: '$totalCustomer',
              color: AppColors.pinkAccent,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.pinkSoft),
          Expanded(
            child: _SummaryItem(
              icon: Icons.payments_rounded,
              label: 'Total Belanja',
              value: Format.rupiahShort(totalRevenue),
              color: AppColors.mintDeep,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.pinkSoft),
          Expanded(
            child: _SummaryItem(
              icon: Icons.savings_rounded,
              label: 'Rata-rata',
              value: Format.rupiahShort(avgPerCustomer),
              color: AppColors.coral,
            ),
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
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AppDimens.xs),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        Text(value, style: AppTextStyles.h3.copyWith(color: color, fontSize: 14)),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.rank,
    required this.customer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final int rank;
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(rank);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: AppTextStyles.h3.copyWith(color: rankColor, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(customer.name, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                        ),
                        const SizedBox(width: AppDimens.xs),
                        if (rank == 1) const KawaiiBadge(label: '👑', variant: BadgeVariant.amber),
                        if (rank == 2) const KawaiiBadge(label: '🥈', variant: BadgeVariant.lavender),
                        if (rank == 3) const KawaiiBadge(label: '🥉', variant: BadgeVariant.coral),
                      ],
                    ),
                    if (customer.whatsapp != null)
                      Text(customer.whatsapp!, style: AppTextStyles.caption),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              _MiniStat(
                icon: Icons.shopping_cart_rounded,
                label: '${customer.totalTransactions} transaksi',
              ),
              const SizedBox(width: AppDimens.md),
              _MiniStat(
                icon: Icons.payments_rounded,
                label: Format.rupiahShort(customer.totalPurchase),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.pinkAccent;
    }
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
      ],
    );
  }
}
