import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'ribbon_painter.dart';

/// 🎀 Widget pita kawaii sebagai aksen header.
class RibbonDecoration extends StatelessWidget {
  const RibbonDecoration({
    super.key,
    this.width = 80,
    this.height = 44,
    this.ribbonColor = AppColors.pinkAccent,
    this.loopColor = AppColors.pinkDeep,
  });

  final double width;
  final double height;
  final Color ribbonColor;
  final Color loopColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: RibbonPainter(ribbonColor: ribbonColor, loopColor: loopColor),
      ),
    );
  }
}
