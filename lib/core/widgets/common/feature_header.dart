import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../ornament/flower_decoration.dart';
import '../ornament/sparkle_field.dart';

/// 🎀 Header layar fitur dengan gradient pink + sparkle + judul manis.
class FeatureHeader extends StatelessWidget {
  const FeatureHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onAction,
    this.actionIcon = Icons.add_rounded,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Positioned.fill(child: SparkleField(count: 12, color: AppColors.sparkleYellow)),
            Positioned(top: 16, right: 18, child: FlowerDecoration(size: 38, petalColor: AppColors.white.withValues(alpha: 0.85))),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.xl, AppDimens.lg, AppDimens.xl, AppDimens.xxxl),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.white, size: AppDimens.iconMd),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.h2.copyWith(color: AppColors.white, fontSize: 20)),
                        Text(subtitle,
                            style: AppTextStyles.caption.copyWith(color: AppColors.white.withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                  if (onAction != null)
                    GestureDetector(
                      onTap: onAction,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.pinkDeep.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Icon(actionIcon, color: AppColors.pinkDeep),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
