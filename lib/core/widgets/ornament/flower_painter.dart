import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// 🌸 CustomPainter yang menggambar bunga kawaii 5 kelopak.
class FlowerPainter extends CustomPainter {
  FlowerPainter({
    this.petalColor = AppColors.pinkAccent,
    this.centerColor = AppColors.sparkleYellow,
    this.petals = 5,
  });

  final Color petalColor;
  final Color centerColor;
  final int petals;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double petalRadius = size.shortestSide * 0.32;
    final double ringRadius = size.shortestSide * 0.22;

    final Paint petalPaint = Paint()..color = petalColor;
    final Paint petalHighlight = Paint()..color = petalColor.withValues(alpha: 0.55);

    // Gambar kelopak.
    for (int i = 0; i < petals; i++) {
      final double angle = (i * 2 * math.pi) / petals;
      final Offset petalCenter = Offset(
        center.dx + math.cos(angle) * ringRadius,
        center.dy + math.sin(angle) * ringRadius,
      );

      // Kelopak utama.
      canvas.drawCircle(petalCenter, petalRadius, petalPaint);
      // Highlight lebih muda di dalam.
      canvas.drawCircle(
        Offset(
          petalCenter.dx - petalRadius * 0.18,
          petalCenter.dy - petalRadius * 0.18,
        ),
        petalRadius * 0.55,
        petalHighlight,
      );
    }

    // Tengah bunga (kuning).
    final Paint centerPaint = Paint()..color = centerColor;
    canvas.drawCircle(center, ringRadius * 0.85, centerPaint);
    // Titik tengah gelap manis.
    canvas.drawCircle(
      center,
      ringRadius * 0.35,
      centerPaint..color = centerColor.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant FlowerPainter oldDelegate) =>
      oldDelegate.petalColor != petalColor ||
      oldDelegate.centerColor != centerColor ||
      oldDelegate.petals != petals;
}
