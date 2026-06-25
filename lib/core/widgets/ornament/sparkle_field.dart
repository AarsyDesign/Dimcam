import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'sparkle_painter.dart';

/// ✨ Lapangan sparkle yang berkedip halus (animasi).
/// Letakkan sebagai background dekoratif pada area header/splash.
class SparkleField extends StatefulWidget {
  const SparkleField({
    super.key,
    this.count = 12,
    this.color = AppColors.sparkleYellow,
    this.seed = 7,
    this.animate = true,
  });

  final int count;
  final Color color;
  /// Seed acak agar posisi konsisten antar rebuild.
  final int seed;
  final bool animate;

  @override
  State<SparkleField> createState() => _SparkleFieldState();
}

class _SparkleFieldState extends State<SparkleField> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<SparkleSpec> _sparkles;
  late final List<double> _phases;

  @override
  void initState() {
    super.initState();
    final math.Random rng = math.Random(widget.seed);
    _sparkles = List.generate(widget.count, (i) {
      return SparkleSpec(
        rng.nextDouble(),
        rng.nextDouble(),
        0.012 + rng.nextDouble() * 0.025,
        rotation: rng.nextDouble() * math.pi,
      );
    });
    _phases = List.generate(widget.count, (_) => rng.nextDouble() * math.pi * 2);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _AnimatedSparklePainter(
            color: widget.color,
            sparkles: _sparkles,
            phases: _phases,
            progress: widget.animate ? _controller.value : 0,
          ),
        );
      },
    );
  }
}

class _AnimatedSparklePainter extends CustomPainter {
  _AnimatedSparklePainter({
    required this.color,
    required this.sparkles,
    required this.phases,
    required this.progress,
  });

  final Color color;
  final List<SparkleSpec> sparkles;
  final List<double> phases;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < sparkles.length; i++) {
      final SparkleSpec s = sparkles[i];
      // Berkedip 0.3..1.0.
      final double t = (math.sin(progress * 2 * math.pi + phases[i]) + 1) / 2;
      final double alpha = 0.35 + t * 0.65;
      final double scale = 0.7 + t * 0.5;

      final Paint paint = Paint()..color = color.withValues(alpha: alpha);
      final Offset center = Offset(s.x * size.width, s.y * size.height);
      final double r = s.size * size.shortestSide * scale;

      _drawSparkle(canvas, paint, center, r, s.rotation);
    }
  }

  void _drawSparkle(Canvas canvas, Paint paint, Offset center, double r, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final Path path = Path();
    const int points = 4;
    const double inner = 0.32;
    for (int i = 0; i < points * 2; i++) {
      final double radius = i.isEven ? r : r * inner;
      final double angle = (i * math.pi) / points;
      path.lineTo(math.cos(angle) * radius, math.sin(angle) * radius);
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AnimatedSparklePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color;
}
