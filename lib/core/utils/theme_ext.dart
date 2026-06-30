import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

extension ThemeExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get scaffoldBg => isDark ? const Color(0xFF16161E) : AppColors.cream;
  Color get cardBg => isDark ? const Color(0xFF2A2A3C) : AppColors.white;
  Color get surfaceCardBg => isDark ? const Color(0xFF2A2A3C) : AppColors.white;
  Color get surfacePink => isDark ? const Color(0xFF2E1F2A) : AppColors.pinkLight;
  Color get surfaceIvory => isDark ? const Color(0xFF2E1F2A) : AppColors.ivory;
  Color get textPrimary => isDark ? AppColors.pinkPastel : AppColors.textDark;
  Color get textBody => isDark ? AppColors.pinkPastel : AppColors.textBrown;
  Color get textMutedColor => isDark ? AppColors.lavender : AppColors.textMuted;
  Color get borderColor => isDark ? AppColors.pinkDeep.withValues(alpha: 0.3) : AppColors.pinkSoft;
  Color get cardBorderColor => isDark ? AppColors.pinkDeep.withValues(alpha: 0.2) : AppColors.pinkSoft;
  Color get dividerColor => isDark ? AppColors.pinkDeep.withValues(alpha: 0.2) : AppColors.pinkSoft;
}
