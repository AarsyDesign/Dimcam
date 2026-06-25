import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.emoji,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (emoji != null)
            Text(emoji!, style: const TextStyle(fontSize: 64))
          else
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? AppColors.pinkDeep.withValues(alpha: 0.3) : AppColors.pinkSoft,
                    isDark ? AppColors.pinkAccent.withValues(alpha: 0.15) : AppColors.pinkLight,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.pinkDeep.withValues(alpha: 0.1)
                        : AppColors.pinkDeep.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, size: 44, color: AppColors.pinkAccent),
            ),
          const SizedBox(height: AppDimens.xl),
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: isDark ? const Color(0xFFE8D5DA) : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppDimens.xs),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? const Color(0xFF9E8E93) : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppDimens.xl),
            action!,
          ],
        ],
      ),
    );
  }
}
