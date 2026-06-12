import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/home_controller.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: ctrl.updateBannerIndex,
            itemCount: ctrl.banners.length,
            itemBuilder: (_, index) {
              final banner = ctrl.banners[index];
              final bgColor =
                  Color(int.parse('FF${banner.backgroundColor}', radix: 16));
              final isGreen = banner.backgroundColor == '2D6A4F' ||
                  banner.backgroundColor == '52B788';

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _BannerCard(
                  title: banner.title,
                  subtitle: banner.subtitle,
                  actionLabel: banner.actionLabel ?? 'Lihat',
                  bgColor: bgColor,
                  isGreen: isGreen,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                ctrl.banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: ctrl.currentBannerIndex.value == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: ctrl.currentBannerIndex.value == index
                        ? AppColors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final Color bgColor;
  final bool isGreen;

  const _BannerCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.bgColor,
    required this.isGreen,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isGreen ? Colors.white : AppColors.textPrimary;
    final subColor =
        isGreen ? Colors.white.withOpacity(0.85) : AppColors.textSecondary;
    final btnColor =
        isGreen ? Colors.white : AppColors.textPrimary;
    final btnTextColor = isGreen ? AppColors.secondary : AppColors.surface;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Corn emoji decoration
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '🌽',
                style: TextStyle(fontSize: 64),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: textColor,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: subColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  ),
                  child: Text(
                    actionLabel,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: btnTextColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
