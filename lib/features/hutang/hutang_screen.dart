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
import '../../data/models/debt.dart';
import '../../providers/debt_provider.dart';
import 'debt_form_screen.dart';

class HutangScreen extends StatefulWidget {
  const HutangScreen({super.key});

  @override
  State<HutangScreen> createState() => _HutangScreenState();
}

class _HutangScreenState extends State<HutangScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addDebt() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DebtFormScreen()),
    ).then((_) {
      if (mounted) context.read<DebtProvider>().refresh();
    });
  }

  void _editDebt(Debt debt) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DebtFormScreen(debt: debt)),
    ).then((_) {
      if (mounted) context.read<DebtProvider>().refresh();
    });
  }

  void _viewDetail(Debt debt) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXxl)),
      ),
      builder: (ctx) => _DebtDetailSheet(
        debt: debt,
        onEdit: () {
          Navigator.pop(ctx);
          _editDebt(debt);
        },
        onToggleStatus: () => _toggleStatus(debt),
        onDelete: () => _deleteDebt(debt),
      ),
    );
  }

  Future<void> _toggleStatus(Debt debt) async {
    final newStatus = debt.isPaid ? DebtStatus.unpaid : DebtStatus.paid;
    await context.read<DebtProvider>().update(debt.copyWith(status: newStatus));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus == DebtStatus.paid ? 'Hutang ditandai lunas' : 'Hutang dikembalikan ke belum lunas')),
      );
    }
  }

  Future<void> _deleteDebt(Debt debt) async {
    final provider = context.read<DebtProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXl)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.coral),
            const SizedBox(width: AppDimens.sm),
            Text('Hapus Hutang?', style: AppTextStyles.h3),
          ],
        ),
        content: Text(
          'Hutang ${debt.customerName} sebesar ${Format.rupiah(debt.amount)} akan dihapus permanen.',
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
      await provider.remove(debt.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hutang berhasil dihapus')),
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
            title: 'Hutang',
            subtitle: 'Piutang pelanggan',
            icon: Icons.receipt_long_rounded,
            onAction: _addDebt,
          ),
          Expanded(
            child: Consumer<DebtProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.pinkAccent),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.pinkAccent,
                  onRefresh: () => provider.refresh(),
                  child: Column(
                    children: [
                      _SummaryBar(provider: provider),
                      _SearchBar(
                        controller: _searchController,
                        provider: provider,
                      ),
                      _FilterChips(provider: provider),
                      Expanded(
                        child: provider.filteredItems.isEmpty
                            ? const EmptyState(
                                icon: Icons.receipt_long_rounded,
                                title: 'Belum ada hutang',
                                subtitle: 'Tambahkan hutang dengan tap tombol +',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    AppDimens.lg, 0, AppDimens.lg, AppDimens.xxxl),
                                itemCount: provider.filteredItems.length,
                                itemBuilder: (context, index) {
                                  final debt = provider.filteredItems[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppDimens.md),
                                    child: _DebtCard(
                                      debt: debt,
                                      onTap: () => _viewDetail(debt),
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

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.provider});
  final DebtProvider provider;

  @override
  Widget build(BuildContext context) {
    final unpaid = provider.totalPiutang;
    final overdue = provider.totalJatuhTempo;
    final paid = provider.totalLunas;

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
        children: [
          Row(
            children: [
              _SummaryItem(
                icon: Icons.receipt_long_rounded,
                label: 'Piutang',
                value: Format.rupiahShort(unpaid),
                color: AppColors.coral,
              ),
              Container(width: 1, height: 40, color: AppColors.pinkSoft),
              _SummaryItem(
                icon: Icons.warning_rounded,
                label: 'Jatuh Tempo',
                value: Format.rupiahShort(overdue),
                color: AppColors.amber,
              ),
              Container(width: 1, height: 40, color: AppColors.pinkSoft),
              _SummaryItem(
                icon: Icons.check_circle_rounded,
                label: 'Lunas',
                value: Format.rupiahShort(paid),
                color: AppColors.mintDeep,
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
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppDimens.xs),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
          Text(value, style: AppTextStyles.h3.copyWith(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.controller, required this.provider});
  final TextEditingController controller;
  final DebtProvider provider;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
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

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.provider});
  final DebtProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.md, AppDimens.lg, AppDimens.md),
      child: Row(
        children: [
          _FilterChip(
            label: 'Semua',
            selected: provider.filterStatus == null,
            onTap: () => provider.setFilterStatus(null),
          ),
          const SizedBox(width: AppDimens.xs),
          _FilterChip(
            label: 'Belum Lunas',
            selected: provider.filterStatus == DebtStatus.unpaid,
            onTap: () => provider.setFilterStatus(DebtStatus.unpaid),
          ),
          const SizedBox(width: AppDimens.xs),
          _FilterChip(
            label: 'Lunas',
            selected: provider.filterStatus == DebtStatus.paid,
            onTap: () => provider.setFilterStatus(DebtStatus.paid),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs + 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.pinkAccent : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: Border.all(
            color: selected ? AppColors.pinkAccent : AppColors.pinkSoft,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? AppColors.white : AppColors.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({
    required this.debt,
    required this.onTap,
  });

  final Debt debt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: debt.isPaid ? AppColors.mint.withValues(alpha: 0.3) : AppColors.coral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                ),
                child: Center(
                  child: Icon(
                    debt.isPaid ? Icons.check_circle_rounded : Icons.person_rounded,
                    color: debt.isPaid ? AppColors.mintDeep : AppColors.coral,
                    size: 24,
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
                          child: Text(debt.customerName, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                        ),
                        const SizedBox(width: AppDimens.xs),
                        KawaiiBadge(
                          label: debt.statusLabel,
                          variant: debt.isPaid ? BadgeVariant.mint : BadgeVariant.coral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (debt.whatsapp != null && debt.whatsapp!.isNotEmpty)
                      Text(debt.whatsapp!, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Format.rupiah(debt.amount),
                    style: AppTextStyles.h3.copyWith(
                      color: debt.isPaid ? AppColors.mintDeep : AppColors.coral,
                      fontSize: 16,
                    ),
                  ),
                  if (debt.isOverdue)
                    const KawaiiBadge(label: 'Overdue', variant: BadgeVariant.amber),
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
                DateFormat('EEEE, d MMM yyyy', 'id_ID').format(debt.dateTime),
                style: AppTextStyles.caption,
              ),
              if (debt.note != null && debt.note!.isNotEmpty) ...[
                const SizedBox(width: AppDimens.md),
                const Icon(Icons.note_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    debt.note!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DebtDetailSheet extends StatelessWidget {
  const _DebtDetailSheet({
    required this.debt,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final Debt debt;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.pinkSoft,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: debt.isPaid ? AppColors.mint.withValues(alpha: 0.3) : AppColors.coral.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    debt.isPaid ? Icons.check_circle_rounded : Icons.person_rounded,
                    color: debt.isPaid ? AppColors.mintDeep : AppColors.coral,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(debt.customerName, style: AppTextStyles.h2),
                    if (debt.whatsapp != null)
                      Text(debt.whatsapp!, style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              KawaiiBadge(
                label: debt.statusLabel,
                variant: debt.isPaid ? BadgeVariant.mint : BadgeVariant.coral,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.xl),
          Row(
            children: [
              _DetailItem(label: 'Nominal', value: Format.rupiah(debt.amount)),
              _DetailItem(label: 'Tanggal', value: DateFormat('d MMM yyyy', 'id_ID').format(debt.dateTime)),
              _DetailItem(
                label: 'Status',
                value: debt.isOverdue ? 'Jatuh Tempo' : debt.statusLabel,
              ),
            ],
          ),
          if (debt.note != null && debt.note!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.lg),
            Row(
              children: [
                const Icon(Icons.note_rounded, size: 18, color: AppColors.textMuted),
                const SizedBox(width: AppDimens.sm),
                Text(debt.note!, style: AppTextStyles.body),
              ],
            ),
          ],
          const SizedBox(height: AppDimens.xxl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(debt.isPaid ? Icons.undo_rounded : Icons.check_rounded),
                  label: Text(debt.isPaid ? 'Batal Lunas' : 'Tandai Lunas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: debt.isPaid ? AppColors.amber : AppColors.mintDeep,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodyBold, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

