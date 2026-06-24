import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// 🎀 CustomPainter pita kawaii sebagai header section / dekorasi.
class RibbonPainter extends CustomPainter {
  RibbonPainter({
    this.ribbonColor = AppColors.pinkAccent,
    this.loopColor = AppColors.pinkDeep,
  });

  final Color ribbonColor;
  final Color loopColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = ribbonColor;
    final Paint loopPaint = Paint()..color = loopColor;

    final double w = size.width;
    final double h = size.height;
    final double knotW = w * 0.18;
    final double knotH = h * 0.5;
    final Offset center = Offset(w / 2, h / 2);

    // Loop kiri.
    final Path leftLoop = Path();
    leftLoop.moveTo(center.dx, center.dy - knotH / 2);
    leftLoop.quadraticBezierTo(
      center.dx - knotW * 2.4, center.dy - knotH * 1.6,
      center.dx - knotW * 1.8, center.dy,
    );
    leftLoop.quadraticBezierTo(
      center.dx - knotW * 2.4, center.dy + knotH * 1.6,
      center.dx, center.dy + knotH / 2,
    );
    leftLoop.close();
    canvas.drawPath(leftLoop, paint);
    // Lipatan loop kiri.
    canvas.drawPath(leftLoop, Paint()..color = loopColor.withValues(alpha: 0.25)..style = PaintingStyle.fill);

    // Loop kanan (mirror).
    final Path rightLoop = Path();
    rightLoop.moveTo(center.dx, center.dy - knotH / 2);
    rightLoop.quadraticBezierTo(
      center.dx + knotW * 2.4, center.dy - knotH * 1.6,
      center.dx + knotW * 1.8, center.dy,
    );
    rightLoop.quadraticBezierTo(
      center.dx + knotW * 2.4, center.dy + knotH * 1.6,
      center.dx, center.dy + knotH / 2,
    );
    rightLoop.close();
    canvas.drawPath(rightLoop, paint);
    canvas.drawPath(rightLoop, Paint()..color = loopColor.withValues(alpha: 0.25)..style = PaintingStyle.fill);

    // Simpul tengah.
    final RRect knot = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: knotW, height: knotH),
      const Radius.circular(8),
    );
    canvas.drawRRect(knot, loopPaint);

    // Ujung ekor pita.
    final Path tailLeft = Path();
    tailLeft.moveTo(center.dx - knotW * 0.5, center.dy + knotH * 0.3);
    tailLeft.lineTo(center.dx - knotW * 1.4, h);
    tailLeft.lineTo(center.dx - knotW * 0.2, h);
    tailLeft.close();
    canvas.drawPath(tailLeft, paint);

    final Path tailRight = Path();
    tailRight.moveTo(center.dx + knotW * 0.5, center.dy + knotH * 0.3);
    tailRight.lineTo(center.dx + knotW * 1.4, h);
    tailRight.lineTo(center.dx + knotW * 0.2, h);
    tailRight.close();
    canvas.drawPath(tailRight, paint);
  }

  @override
  bool shouldRepaint(covariant RibbonPainter oldDelegate) =>
      oldDelegate.ribbonColor != ribbonColor || oldDelegate.loopColor != loopColor;
}
