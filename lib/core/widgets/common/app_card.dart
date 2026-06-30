import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../utils/theme_ext.dart';

/// 💳 Kartu rounded dengan soft shadow lembut + border pink tipis.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.cardPadding),
    this.margin,
    this.color,
    this.border,
    this.onTap,
    this.radius = AppDimens.radiusXl,
    this.shadowColor = const Color(0xFFF4B4C4),
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Border? border;
  final VoidCallback? onTap;
  final double radius;
  final Color shadowColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? context.cardBg) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: context.cardBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: (context.isDark ? Colors.black.withValues(alpha: 0.4) : shadowColor.withValues(alpha: 0.35)),
            blurRadius: AppDimens.blurSoft,
            offset: Offset(0, context.isDark ? 4 : 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
