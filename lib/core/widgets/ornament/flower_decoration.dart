import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'flower_painter.dart';

/// 🌸 Widget bunga kawaii statis dengan ukuran & warna bisa diatur.
class FlowerDecoration extends StatelessWidget {
  const FlowerDecoration({
    super.key,
    this.size = 48,
    this.petalColor = AppColors.pinkAccent,
    this.centerColor = AppColors.sparkleYellow,
    this.petals = 5,
  });

  final double size;
  final Color petalColor;
  final Color centerColor;
  final int petals;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: FlowerPainter(
          petalColor: petalColor,
          centerColor: centerColor,
          petals: petals,
        ),
      ),
    );
  }
}
