import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ornament/flower_decoration.dart';
import '../../core/widgets/ornament/sparkle_field.dart';
import '../main/main_navigation.dart';

/// 🌸 Splash screen dengan logo animasi + sparkle + bunga kawaii.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logo;
  late final AnimationController _text;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();

    _logo = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _text = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _logoScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _logo, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logo, curve: Curves.easeIn),
    );

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logo.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _text.forward();
    await Future.delayed(const Duration(milliseconds: 2400));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const MainNavigation(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logo.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Sparkle lapangan.
              const Positioned.fill(child: SparkleField(count: 18, color: AppColors.sparkleYellow)),

              // Bunga dekoratif pojok.
              Positioned(top: 40, left: 24, child: FlowerDecoration(size: 46, petalColor: AppColors.white.withValues(alpha: 0.85))),
              Positioned(top: 70, right: 30, child: FlowerDecoration(size: 34, petalColor: AppColors.sparkleYellow)),
              Positioned(bottom: 60, left: 40, child: FlowerDecoration(size: 38, petalColor: AppColors.lavender)),
              Positioned(bottom: 90, right: 24, child: FlowerDecoration(size: 52, petalColor: AppColors.white.withValues(alpha: 0.9))),

              // Konten tengah.
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo.
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: _Logo(),
                      ),
                    ),
                    const SizedBox(height: AppDimens.xxl),

                    // Judul.
                    FadeTransition(
                      opacity: _text,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(_text),
                        child: Column(
                          children: [
                            Text(
                              'Dimsumia',
                              style: AppTextStyles.display.copyWith(
                                color: AppColors.white,
                                fontSize: 40,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Manager',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: AppDimens.md),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.xs),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.favorite, size: 14, color: AppColors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Manajer Dimsum Manis',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.favorite, size: 14, color: AppColors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer.
              Positioned(
                bottom: AppDimens.xxxl,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _text,
                  child: Text(
                    'Dibuat dengan 💖 untuk dimsum lezat',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(color: AppColors.white.withValues(alpha: 0.85)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo aplikasi — menggunakan asset gambar bila tersedia, fallback emoji kawaii.
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.pinkDeep.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran gradient dalam.
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.pinkSoft, AppColors.ivory],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
          ),
          // Logo asset bila ada.
          Image.asset(
            'assets/images/logo.png',
            width: 78,
            height: 78,
            errorBuilder: (_, __, ___) => const Text('🥟', style: TextStyle(fontSize: 56)),
          ),
        ],
      ),
    );
  }
}
