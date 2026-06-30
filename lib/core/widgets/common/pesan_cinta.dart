import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PesanCinta extends StatelessWidget {
  const PesanCinta({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.sm),
  });

  final EdgeInsets padding;

  static const _messages = [
    'Untuk Nabila tersayang — semoga hari ini seindah senyummu 💕',
    'Dengan cinta untukmu, Nabila 🌸',
    'Setiap langkahmu adalah inspirasi, Nabila Salsabila Wardana 🌷',
    'Cintaku untukmu tak pernah berhenti tumbuh 💖',
    'Bersamamu, hari-hari selalu manis 🥟',
    'Kamu adalah alasan di balik semua ini, Nabila 🌸',
    'Dedikasimu untuk usaha ini membuatku makin bangga 💕',
    'Selamat bekerja, cintaku! Semoga hari ini penuh berkah 🤲',
  ];

  String get _todayMessage => _messages[DateTime.now().day % _messages.length];

  @override
  Widget build(BuildContext context) {
    final msg = _todayMessage;
    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, color: AppColors.pinkAccent, size: 14),
          const SizedBox(width: AppDimens.xs),
          Flexible(
            child: Text(
              msg,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white.withValues(alpha: 0.95),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppDimens.xs),
          const Icon(Icons.favorite_rounded, color: AppColors.pinkAccent, size: 14),
        ],
      ),
    );
  }
}
