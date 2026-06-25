import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class HppScreen extends StatelessWidget {
  const HppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Text('HPP Screen - Coming Soon'),
      ),
    );
  }
}
