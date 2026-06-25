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
import '../../data/models/customer.dart';
import '../../providers/customer_provider.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  final Customer customer;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Customer? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    final detail = await context.read<CustomerProvider>().getDetail(widget.customer.id);
    if (mounted) {
      setState(() {
        _detail = detail ?? widget.customer;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _detail ?? widget.customer;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.pinkAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detail Pelanggan', style: AppTextStyles.h3.copyWith(color: AppColors.white)),
      ),
      body: RefreshIndicator(
        color: AppColors.pinkAccent,
        onRefresh: _loadDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileCard(customer: c),
              const SizedBox(height: AppDimens.lg),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimens.xl),
                    child: CircularProgressIndicator(color: AppColors.pinkAccent),
                  ),
                )
              else ...[
                _StatsCard(customer: c),
                const SizedBox(height: AppDimens.lg),
                _InfoCard(customer: c),
                if (c.favoriteProduct != null) ...[
                  const SizedBox(height: AppDimens.lg),
                  _FavoriteCard(customer: c),
                ],
              ],
              const SizedBox(height: AppDimens.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.customer});
  final Customer customer;

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
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: AppTextStyles.h1.copyWith(color: AppColors.white, fontSize: 34),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Text(customer.name, style: AppTextStyles.h2),
          const SizedBox(height: AppDimens.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const KawaiiBadge(label: 'Pelanggan', variant: BadgeVariant.pink),
              const SizedBox(width: AppDimens.xs),
              KawaiiBadge(
                label: 'ID ${customer.id}',
                variant: BadgeVariant.lavender,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(
                icon: Icons.analytics_rounded,
                color: AppColors.lavender,
                iconColor: AppColors.pinkDeep,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Aktivitas', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.shopping_cart_rounded,
                  label: 'Transaksi',
                  value: '${customer.totalTransactions}',
                  color: AppColors.pinkAccent,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.pinkSoft),
              Expanded(
                child: _StatItem(
                  icon: Icons.payments_rounded,
                  label: 'Total Belanja',
                  value: Format.rupiahShort(customer.totalPurchase),
                  color: AppColors.mintDeep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.h3.copyWith(color: color, fontSize: 18)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.customer});
  final Customer customer;

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
                color: AppColors.coral,
                iconColor: AppColors.white,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Informasi', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          if (customer.whatsapp != null) ...[
            _InfoRow(
              icon: Icons.phone_rounded,
              label: 'WhatsApp',
              value: customer.whatsapp!,
            ),
            const SizedBox(height: AppDimens.md),
          ],
          if (customer.address != null) ...[
            _InfoRow(
              icon: Icons.location_on_rounded,
              label: 'Alamat',
              value: customer.address!,
            ),
            const SizedBox(height: AppDimens.md),
          ],
          if (customer.note != null) ...[
            _InfoRow(
              icon: Icons.note_rounded,
              label: 'Catatan',
              value: customer.note!,
            ),
            const SizedBox(height: AppDimens.md),
          ],
          if (customer.createdAt != null)
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Terdaftar',
              value: DateFormat('d MMMM yyyy', 'id_ID').format(customer.createdAt!),
            ),
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

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.pinkLight, AppColors.ivory],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(
                icon: Icons.emoji_events_rounded,
                color: AppColors.amber,
                iconColor: AppColors.white,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Produk Favorit', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                customer.favoriteProductEmoji ?? '🥟',
                style: const TextStyle(fontSize: 44),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.favoriteProduct!,
                      style: AppTextStyles.h3.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paling sering dibeli',
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
}
