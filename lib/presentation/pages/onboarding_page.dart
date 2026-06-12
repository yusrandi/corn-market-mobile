import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  late final AnimationController _illustrationCtrl;
  late final Animation<double> _illustrationScale;
  late final Animation<double> _illustrationFade;

  late final AnimationController _contentCtrl;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;

  static const _pages = [
    _OnboardingData(
      emoji: '🌽',
      title: 'Jagung Segar\nLangsung dari Kebun',
      subtitle:
          'Dipanen pagi, sampai ke tanganmu siang hari. Kesegaran dijamin dari petani lokal Kalimantan Timur.',
      bg1: Color(0xFFFFF8E7),
      bg2: Color(0xFFFFF0A0),
      accent: Color(0xFFF5C518),
    ),
    _OnboardingData(
      emoji: '🚚',
      title: 'Pengiriman Cepat\nse-Kalimantan',
      subtitle:
          'Gratis ongkir untuk pembelian di atas Rp 100.000. Estimasi tiba 1–2 hari kerja ke seluruh Kaltim.',
      bg1: Color(0xFFECFDF5),
      bg2: Color(0xFFD8F3DC),
      accent: Color(0xFF2D6A4F),
    ),
    _OnboardingData(
      emoji: '⭐',
      title: 'Ribuan Pembeli\nSudah Puas',
      subtitle:
          'Rating 4.9 dari lebih dari 10.000 pelanggan. Bergabung dan rasakan sendiri kualitas jagung pilihan kami.',
      bg1: Color(0xFFF0FDF4),
      bg2: Color(0xFFBBF7D0),
      accent: Color(0xFF52B788),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _illustrationCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _illustrationScale = CurvedAnimation(
            parent: _illustrationCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.4, end: 1.0));
    _illustrationFade =
        CurvedAnimation(parent: _illustrationCtrl, curve: Curves.easeIn)
            .drive(Tween(begin: 0.0, end: 1.0));

    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentSlide =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic)
            .drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));
    _contentFade =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeIn)
            .drive(Tween(begin: 0.0, end: 1.0));

    _playEntrance();
  }

  Future<void> _playEntrance() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _illustrationCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 200));
    _contentCtrl.forward(from: 0);
  }

  Future<void> _onPageChanged(int page) async {
    setState(() => _currentPage = page);
    _illustrationCtrl.forward(from: 0);
    _contentCtrl.forward(from: 0);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void _skip() => Get.offAllNamed(AppRoutes.login);

  @override
  void dispose() {
    _pageCtrl.dispose();
    _illustrationCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final page = _pages[_currentPage];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [page.bg1, page.bg2],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                  child: _currentPage < _pages.length - 1
                      ? TextButton(
                          onPressed: _skip,
                          child: Text(
                            'Lewati',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : const SizedBox(height: 40),
                ),
              ),

              // Illustration area
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _IllustrationSlide(
                    data: _pages[i],
                    illustrationScale: _illustrationScale,
                    illustrationFade: _illustrationFade,
                    size: size,
                  ),
                ),
              ),

              // Content area
              Expanded(
                flex: 4,
                child: SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // Page dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_pages.length, (i) {
                              final isActive = i == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? page.accent
                                      : page.accent.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 28),

                          // Title
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.displayMedium.copyWith(
                              height: 1.25,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge.copyWith(
                              height: 1.7,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          const Spacer(),

                          // CTA button
                          _CTAButton(
                            label: _currentPage < _pages.length - 1
                                ? 'Selanjutnya'
                                : 'Mulai Belanja 🌽',
                            accent: page.accent,
                            onTap: _next,
                            isLast: _currentPage == _pages.length - 1,
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
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

// ─── Data model ──────────────────────────────────────────────────────────────

class _OnboardingData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bg1;
  final Color bg2;
  final Color accent;

  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bg1,
    required this.bg2,
    required this.accent,
  });
}

// ─── Illustration slide ───────────────────────────────────────────────────────

class _IllustrationSlide extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> illustrationScale;
  final Animation<double> illustrationFade;
  final Size size;

  const _IllustrationSlide({
    required this.data,
    required this.illustrationScale,
    required this.illustrationFade,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([illustrationScale, illustrationFade]),
      builder: (_, __) => Opacity(
        opacity: illustrationFade.value,
        child: Transform.scale(
          scale: illustrationScale.value,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: size.width * 0.68,
                  height: size.width * 0.68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.accent.withOpacity(0.08),
                  ),
                ),
                // Middle ring
                Container(
                  width: size.width * 0.52,
                  height: size.width * 0.52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.accent.withOpacity(0.13),
                  ),
                ),
                // Inner circle
                Container(
                  width: size.width * 0.38,
                  height: size.width * 0.38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.accent.withOpacity(0.18),
                    boxShadow: [
                      BoxShadow(
                        color: data.accent.withOpacity(0.25),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      data.emoji,
                      style: TextStyle(fontSize: size.width * 0.16),
                    ),
                  ),
                ),

                // Floating particles
                ..._buildParticles(size, data.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParticles(Size size, Color accent) {
    final positions = [
      (-size.width * 0.28, -size.width * 0.08, 0.10, 18.0),
      (size.width * 0.26, -size.width * 0.12, 0.08, 12.0),
      (-size.width * 0.22, size.width * 0.14, 0.07, 14.0),
      (size.width * 0.24, size.width * 0.16, 0.09, 10.0),
      (size.width * 0.02, -size.width * 0.28, 0.06, 8.0),
      (-size.width * 0.06, size.width * 0.26, 0.05, 10.0),
    ];

    return positions.map((p) {
      final (dx, dy, opacity, sz) = p;
      return Positioned(
        left: size.width * 0.5 + dx - sz / 2,
        top: size.width * 0.36 + dy - sz / 2,
        child: Container(
          width: sz,
          height: sz,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withOpacity(opacity),
          ),
        ),
      );
    }).toList();
  }
}

// ─── CTA Button ──────────────────────────────────────────────────────────────

class _CTAButton extends StatefulWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;
  final bool isLast;

  const _CTAButton({
    required this.label,
    required this.accent,
    required this.onTap,
    required this.isLast,
  });

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _pressScale = CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 1.0, end: 0.95));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) async {
        await _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (_, child) =>
            Transform.scale(scale: _pressScale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: widget.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: widget.isLast
                        ? AppColors.textPrimary
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!widget.isLast) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
