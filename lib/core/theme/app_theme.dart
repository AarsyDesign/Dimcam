import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_dimens.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// 🎀 Tema Material 3 Dimsumia Manager.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
      primary: AppColors.pinkAccent,
      secondary: AppColors.lavender,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSurface: AppColors.textDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // ---- App bar ----
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiLight.pink,
        titleTextStyle: AppTextStyles.h2,
        iconTheme: const IconThemeData(color: AppColors.white, size: AppDimens.iconMd),
      ),

      // ---- Card ----
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        ),
        margin: EdgeInsets.zero,
      ),

      // ---- Elevated button ----
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pinkAccent,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl, vertical: AppDimens.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ---- Text button ----
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pinkDeep,
          textStyle: AppTextStyles.button,
        ),
      ),

      // ---- Outlined button ----
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.pinkDeep,
          side: const BorderSide(color: AppColors.pinkAccent, width: 1.5),
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ---- Input ----
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pinkLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.lg),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextStyles.bodyBold.copyWith(color: AppColors.pinkDeep),
        prefixIconColor: AppColors.pinkAccent,
        suffixIconColor: AppColors.pinkAccent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          borderSide: const BorderSide(color: AppColors.pinkSoft, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          borderSide: const BorderSide(color: AppColors.pinkAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          borderSide: const BorderSide(color: AppColors.coral, width: 2),
        ),
      ),

      // ---- FAB ----
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.pinkAccent,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXxl),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: AppDimens.xxl, vertical: AppDimens.lg),
      ),

      // ---- Chip ----
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.pinkSoft,
        selectedColor: AppColors.pinkAccent,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.pinkDeep, fontWeight: FontWeight.w700),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs),
      ),

      // ---- Navigation bar ----
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        height: AppDimens.navBarHeight,
        indicatorColor: AppColors.pinkSoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.pinkDeep : AppColors.textMuted,
            size: AppDimens.iconMd,
          );
        }),
      ),

      // ---- Divider ----
      dividerTheme: const DividerThemeData(
        color: AppColors.pinkSoft,
        thickness: 1,
        space: 1,
      ),

      // ---- Progress ----
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.pinkAccent,
        linearTrackColor: AppColors.pinkSoft,
        linearMinHeight: 8,
        borderRadius: BorderRadius.all(Radius.circular(AppDimens.radiusFull)),
      ),

      // ---- Snack bar ----
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textDark,
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
      ),

      // ---- Bottom sheet ----
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXxl)),
        ),
      ),
    );
  }
}

/// Helper overlay style.
class SystemUiLight {
  static const SystemUiOverlayStyle pink = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}
