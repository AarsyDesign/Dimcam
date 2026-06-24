import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// 🏷️ Badge kecil kawaii dengan varian warna.
class KawaiiBadge extends StatelessWidget {
  const KawaiiBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.pink,
    this.icon,
    this.fontSize = 11,
  });

  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = variant.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        border: Border.all(color: colors.$2, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: colors.$3),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: colors.$3,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

enum BadgeVariant {
  pink,
  mint,
  amber,
  coral,
  lavender,
}

extension BadgeVariantColors on BadgeVariant {
  /// (bg, border, text)
  (Color, Color, Color) get colors => switch (this) {
        BadgeVariant.pink => (AppColors.pinkSoft, AppColors.pinkAccent, AppColors.pinkDeep),
        BadgeVariant.mint => (AppColors.mint, AppColors.mintDeep, AppColors.mintDeep),
        BadgeVariant.amber => (const Color(0xFFFFF3D6), AppColors.amber, const Color(0xFFB57A12)),
        BadgeVariant.coral => (const Color(0xFFFFE2DC), AppColors.coral, const Color(0xFFC45A4A)),
        BadgeVariant.lavender => (AppColors.lavender, const Color(0xFFB79BE0), const Color(0xFF6B4A8C)),
      };
}
