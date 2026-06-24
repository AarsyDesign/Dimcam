import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// ✨ CustomPainter yang menggambar beberapa sparkle (bintang 4 mata) kawaii.
/// Bisa di-overlay di pojok layar untuk efek dekoratif.
class SparklePainter extends CustomPainter {
  SparklePainter({
    this.color = AppColors.sparkleYellow,
    this.sparkles = const [],
  });

  final Color color;
  /// Posisi relatif (0..1, 0..1) dan ukuran relatif tiap sparkle.
  final List<SparkleSpec> sparkles;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;

    for (final SparkleSpec s in sparkles) {
      final Offset center = Offset(s.x * size.width, s.y * size.height);
      final double r = s.size * size.shortestSide;
      _drawSparkle(canvas, paint, center, r, s.rotation);
    }
  }

  void _drawSparkle(Canvas canvas, Paint paint, Offset center, double r, double rotation) {
    canvas.save();
    canvas.translate(center);
    canvas.rotate(rotation);

    final Path path = Path();
    // Bentuk bintang 4 mata (plus) dengan lekukan.
    const int points = 4;
    const double inner = 0.32;
    for (int i = 0; i < points * 2; i++) {
      final double radius = i.isEven ? r : r * inner;
      final double angle = (i * math.pi) / points;
      final double dx = math.cos(angle) * radius;
      final double dy = math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Titik tengah lebih terang.
    canvas.drawCircle(Offset.zero, r * 0.12, paint..color = color.withValues(alpha: 0.6));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.sparkles != sparkles;
}

class SparkleSpec {
  const SparkleSpec(this.x, this.y, this.size, {this.rotation = 0});
  final double x;
  final double y;
  final double size;
  final double rotation;
}
