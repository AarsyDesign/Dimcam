import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// 🎀 Lingkaran ikon berwarna pastel untuk avatar produk / kategori.
class IconBubble extends StatelessWidget {
  const IconBubble({
    super.key,
    required this.icon,
    this.color = AppColors.pinkSoft,
    this.iconColor = AppColors.pinkDeep,
    this.size = 44,
    this.iconSize,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: iconColor.withValues(alpha: 0.18), width: 1),
      ),
      child: Icon(icon, color: iconColor, size: iconSize ?? size * 0.5),
    );
  }
}

/// 🌭 Lingkaran emoji/teks untuk avatar produk (mis. "D" untuk Dimsum Ayam).
class TextBubble extends StatelessWidget {
  const TextBubble({
    super.key,
    required this.text,
    this.gradient = AppColors.pinkGradient,
    this.size = 44,
    this.fontSize = 18,
    this.emoji,
  });

  final String text;
  final Gradient gradient;
  final double size;
  final double fontSize;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.pinkDeep.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: emoji != null
            ? Text(emoji!, style: TextStyle(fontSize: fontSize + 4))
            : Text(
                text,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
