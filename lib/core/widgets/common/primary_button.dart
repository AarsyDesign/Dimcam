import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// 🌸 Tombol utama pink dengan gradient & efek tekan lembut.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
    this.gradient = AppColors.pinkGradient,
    this.height = AppDimens.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final Gradient gradient;
  final double height;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;

    Widget content = Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: enabled ? widget.gradient : const LinearGradient(colors: [AppColors.textMuted, AppColors.textMuted]),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.pinkDeep.withValues(alpha: _pressed ? 0.15 : 0.4),
                  blurRadius: _pressed ? 6 : 14,
                  offset: Offset(0, _pressed ? 2 : 6),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: AppColors.white, size: AppDimens.iconSm),
            const SizedBox(width: AppDimens.sm),
          ],
          Text(widget.label, style: AppTextStyles.button),
        ],
      ),
    );

    content = GestureDetector(
      onTapDown: (_) => enabled ? setState(() => _pressed = true) : null,
      onTapUp: (_) => enabled ? setState(() => _pressed = false) : null,
      onTapCancel: () => enabled ? setState(() => _pressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: content,
      ),
    );

    if (widget.expand) {
      return SizedBox(width: double.infinity, child: content);
    }
    return content;
  }
}
