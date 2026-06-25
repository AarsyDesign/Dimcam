import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_dimens.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// 🎀 Tema Material 3 Dimsumia Manager — Light & Dark.
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

    return _baseTheme(scheme, Brightness.light).copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: _baseAppBar().copyWith(
        systemOverlayStyle: SystemUiLight.pink,
      ),
    );
  }

  static ThemeData get dark {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
      primary: AppColors.pinkAccent,
      secondary: AppColors.lavender,
      surface: const Color(0xFF1E1E2E),
      onPrimary: AppColors.white,
      onSurface: const Color(0xFFE8D5DA),
    );

    return _baseTheme(scheme, Brightness.dark).copyWith(
      scaffoldBackgroundColor: const Color(0xFF16161E),
      appBarTheme: _baseAppBar().copyWith(
        systemOverlayStyle: SystemUiDark.pink,
      ),
    );
  }

  static ThemeData _baseTheme(ColorScheme scheme, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color pinkSoft = isDark ? const Color(0xFF3D2A36) : AppColors.pinkSoft;
    final Color pinkLight = isDark ? const Color(0xFF2E1F2A) : AppColors.pinkLight;
    final Color textMuted = isDark ? const Color(0xFF9E8E93) : AppColors.textMuted;
    final Color cardColor = isDark ? const Color(0xFF252535) : AppColors.white;
    final Color dividerColor = isDark ? const Color(0xFF3A3A4A) : AppColors.pinkSoft;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: isDark ? const Color(0xFF16161E) : AppColors.cream,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.white),
        iconTheme: const IconThemeData(color: AppColors.white, size: AppDimens.iconMd),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        ),
        margin: EdgeInsets.zero,
      ),

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

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pinkDeep,
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.pinkDeep,
          side: BorderSide(color: isDark ? AppColors.pinkDeep : AppColors.pinkAccent, width: 1.5),
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pinkLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.lg),
        hintStyle: AppTextStyles.body.copyWith(color: textMuted),
        labelStyle: AppTextStyles.bodyBold.copyWith(color: AppColors.pinkDeep),
        prefixIconColor: AppColors.pinkAccent,
        suffixIconColor: AppColors.pinkAccent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          borderSide: BorderSide(color: pinkSoft, width: 1.5),
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

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.pinkAccent,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXxl),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: AppDimens.xxl, vertical: AppDimens.lg),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: pinkSoft,
        selectedColor: AppColors.pinkAccent,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.pinkDeep, fontWeight: FontWeight.w700),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs),
      ),

      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.pinkAccent,
        linearTrackColor: pinkSoft,
        linearMinHeight: 8,
        borderRadius: const BorderRadius.all(Radius.circular(AppDimens.radiusFull)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF3A3A4A) : AppColors.textDark,
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXxl)),
        ),
      ),
    );
  }

  static AppBarTheme _baseAppBar() => const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        iconTheme: IconThemeData(color: AppColors.white, size: AppDimens.iconMd),
      );
}

class SystemUiLight {
  static const SystemUiOverlayStyle pink = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}

class SystemUiDark {
  static const SystemUiOverlayStyle pink = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF16161E),
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
