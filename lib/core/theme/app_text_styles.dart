import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// 🖋️ Gaya tipografi Dimsumia — rounded, manis, dan tetap terbaca.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.baloo2();

  // ---- DISPLAY / HEADING ----
  static TextStyle get display => _base.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        height: 1.15,
      );

  static TextStyle get h1 => _base.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.2,
      );

  static TextStyle get h2 => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.25,
      );

  static TextStyle get h3 => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 1.3,
      );

  // ---- BODY ----
  static TextStyle get body => GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textBrown,
        height: 1.5,
      );

  static TextStyle get bodyBold => GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textBrown,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textBrown,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.quicksand(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        height: 1.3,
        letterSpacing: 0.3,
      );

  // ---- SPECIAL ----
  /// Label kapital untuk section (mis. "TOTAL PENJUALAN").
  static TextStyle get overline => GoogleFonts.quicksand(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        height: 1.2,
        letterSpacing: 1.2,
      );

  /// Nominal besar untuk statistik.
  static TextStyle get statValue => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
        height: 1.1,
      );

  /// Tombol.
  static TextStyle get button => GoogleFonts.quicksand(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.2,
        letterSpacing: 0.3,
      );
}
