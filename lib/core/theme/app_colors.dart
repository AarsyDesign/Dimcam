import 'package:flutter/material.dart';

/// 🌸 Palet warna Dimsumia Manager — girly premium.
/// Dominan pink pastel, cream, putih, dengan aksen lavender & mint.
class AppColors {
  AppColors._();

  // ---- PINK SPECTRUM ----
  /// Pink pastel utama (dominan).
  static const Color pinkPastel = Color(0xFFFFD1DC);

  /// Pink lembut untuk background section.
  static const Color pinkSoft = Color(0xFFFFE8EF);

  /// Hot pink aksen cerah.
  static const Color pinkAccent = Color(0xFFF472A8);

  /// Deep rose untuk teks penting & primary action.
  static const Color pinkDeep = Color(0xFFE8557E);

  /// Pink sangat muda untuk gradient.
  static const Color pinkLight = Color(0xFFFFF0F5);

  // ---- NEUTRAL / CREAM ----
  /// Cream background utama.
  static const Color cream = Color(0xFFFFF8F0);

  /// Putih bersih untuk kartu.
  static const Color white = Color(0xFFFFFEFD);

  /// Off-white dengan sentuhan hangat.
  static const Color ivory = Color(0xFFFFFBF6);

  // ---- TEKS ----
  /// Soft brown untuk body text (kawaii & lembut).
  static const Color textBrown = Color(0xFF6B4A50);

  /// Teks gelap kecokelatan untuk heading.
  static const Color textDark = Color(0xFF4A2F36);

  /// Teks muted / hint.
  static const Color textMuted = Color(0xFFB89AA0);

  // ---- AKSEN LAIN ----
  /// Lavender untuk variasi ornamen.
  static const Color lavender = Color(0xFFE6D7F5);

  /// Mint untuk indikator stok aman.
  static const Color mint = Color(0xFFC8E6D0);

  /// Mint deep.
  static const Color mintDeep = Color(0xFF6BAE84);

  /// Kuning lembut untuk sparkle & highlight.
  static const Color sparkleYellow = Color(0xFFFFE9A8);

  /// Amber untuk warning stok menipis.
  static const Color amber = Color(0xFFF6C177);

  /// Coral untuk stok kritis.
  static const Color coral = Color(0xFFEF8B7B);

  // ---- GRADIENTS ----
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD1DC), Color(0xFFF472A8)],
  );

  static const LinearGradient creamPinkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF8F0), Color(0xFFFFE8EF)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF472A8), Color(0xFFE8557E)],
  );

  static const LinearGradient sparkleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE9A8), Color(0xFFF6C177)],
  );

  // ---- M3 SCHEME SEED ----
  /// Seed untuk Material 3 ColorScheme.
  static const Color seed = Color(0xFFF472A8);
}
