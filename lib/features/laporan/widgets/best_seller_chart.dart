import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/report.dart';

class BestSellerChart extends StatelessWidget {
  const BestSellerChart({super.key, required this.items});

  final List<BestSellerItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Tidak ada data'));
    }

    final maxQty = items.map((e) => e.quantity).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final percentage = (item.quantity / maxQty * 100).clamp(0, 100).toDouble();
              
              return _BestSellerItem(
                rank: index + 1,
                item: item,
                percentage: percentage,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BestSellerItem extends StatelessWidget {
  const _BestSellerItem({
    required this.rank,
    required this.item,
    required this.percentage,
  });

  final int rank;
  final BestSellerItem item;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final color = _getRankColor(rank);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: color,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(item.productEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.quantity} terjual',
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Format.rupiahShort(item.revenue),
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.pinkDeep,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'omzet',
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: AppColors.pinkSoft,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.pinkAccent;
    }
  }
}
