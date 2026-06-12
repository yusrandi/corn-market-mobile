import 'package:corn_market/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // Logo scale + fade
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  // Corn "grow" bounce
  late final AnimationController _growCtrl;
  late final Animation<double> _grow;

  // Text slide up
  late final AnimationController _textCtrl;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;

  // Tagline delay
  late final AnimationController _tagCtrl;
  late final Animation<double> _tagFade;

  // Dots loader
  late final AnimationController _dotCtrl;

  // Exit fade
  late final AnimationController _exitCtrl;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    _growCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _grow = CurvedAnimation(parent: _growCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.6, end: 1.0));

    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _textSlide = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic)
        .drive(Tween(begin: const Offset(0, 0.4), end: Offset.zero));
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    _tagCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _tagFade = CurvedAnimation(parent: _tagCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    _dotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();

    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _exitFade = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 1.0, end: 0.0));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _logoCtrl.forward();
    await _growCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    await _tagCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    _dotCtrl.stop();
    await _exitCtrl.forward();

    // Check onboarding seen
    Get.offAllNamed(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _growCtrl.dispose();
    _textCtrl.dispose();
    _tagCtrl.dispose();
    _dotCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitFade,
      builder: (_, child) => Opacity(opacity: _exitFade.value, child: child),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Background radial glow
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 0.9,
                    colors: [
                      AppColors.primaryLight.withOpacity(0.5),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),

            // Corner decorations
            Positioned(
                top: -40,
                left: -40,
                child: _CornerDot(size: 140, opacity: 0.06)),
            Positioned(
                bottom: -60,
                right: -60,
                child: _CornerDot(size: 200, opacity: 0.05)),
            Positioned(
                top: 120,
                right: -20,
                child: _CornerDot(size: 80, opacity: 0.08)),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Corn logo with scale animation
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoScale, _grow]),
                    builder: (_, __) => Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value * _grow.value,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🌽', style: TextStyle(fontSize: 52)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name slide up
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Text(
                        'CornMarket',
                        style: AppTextStyles.displayLarge.copyWith(
                          letterSpacing: -1,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline fade
                  FadeTransition(
                    opacity: _tagFade,
                    child: Text(
                      'Jagung Segar Langsung\ndari Petani Kalimantan',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Animated dots loader
                  FadeTransition(
                    opacity: _tagFade,
                    child: _DotsLoader(controller: _dotCtrl),
                  ),
                ],
              ),
            ),

            // Version bottom
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _tagFade,
                child: Center(
                  child: Text(
                    'v1.0.0',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerDot extends StatelessWidget {
  final double size;
  final double opacity;
  const _CornerDot({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(opacity),
          shape: BoxShape.circle,
        ),
      );
}

class _DotsLoader extends StatelessWidget {
  final AnimationController controller;
  const _DotsLoader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot offset by 0.33
            final t = ((controller.value + i * 0.33) % 1.0);
            final scale = 0.5 + 0.5 * (1 - (2 * t - 1).abs().clamp(0.0, 1.0));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.4 + 0.6 * scale),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
