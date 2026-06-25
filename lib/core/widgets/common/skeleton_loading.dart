import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  const SkeletonLoading({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.child,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final Widget? child;

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFF0E6E8);
    final highlightColor = isDark ? const Color(0xFF4A4A5A) : const Color(0xFFF8F0F2);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
              transform: _SlidingGradientTransform(
                offset: _controller.value,
              ),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcOver,
          child: child,
        );
      },
      child: widget.child ??
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.offset});
  final double offset;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (offset * 2 - 1), 0, 0);
  }
}

/// Skeleton card untuk list loading.
class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFFFFE8EF),
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          SkeletonLoading(width: 44, height: 44, borderRadius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoading(width: 140, height: 14),
                SizedBox(height: 6),
                SkeletonLoading(width: 80, height: 11),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLoading(width: 70, height: 14),
              SizedBox(height: 6),
              SkeletonLoading(width: 40, height: 11),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton untuk summary card (3 kolom).
class SkeletonSummaryRow extends StatelessWidget {
  const SkeletonSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFFFFE8EF),
          width: 1,
        ),
      ),
      child: Row(
        children: List.generate(
          3,
          (_) => const Expanded(
            child: Column(
              children: [
                SkeletonLoading(width: 22, height: 22, borderRadius: 11),
                SizedBox(height: 6),
                SkeletonLoading(width: 50, height: 10),
                SizedBox(height: 4),
                SkeletonLoading(width: 60, height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
