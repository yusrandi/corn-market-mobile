import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/home_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/theme_controller.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final ctrl   = Get.find<HomeController>();
    final cart   = Get.find<CartController>();
    final theme  = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.darkBackground : AppColors.background;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.horizontalPadding, 8,
        AppConstants.horizontalPadding, 8,
      ),
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [
                const Text('🌽', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text('CornMarket', style: AppTextStyles.headlineMedium.copyWith(color: txtPri, letterSpacing: -0.5)),
              ]),
              Text('Balikpapan, Kaltim', style: AppTextStyles.labelLarge.copyWith(color: isDark ? AppColors.darkTextHint : AppColors.textHint)),
            ]),
          ),
          // Dark mode toggle
          Obx(() => _IconButton(
            icon: theme.isDarkMode.value ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
            onTap: theme.toggleTheme,
            isDark: isDark,
          )),
          const SizedBox(width: AppConstants.spacingSM),
          _IconButton(icon: Icons.search_rounded, onTap: ctrl.toggleSearch, isDark: isDark),
          const SizedBox(width: AppConstants.spacingSM),
          Obx(() => Stack(clipBehavior: Clip.none, children: [
            _IconButton(icon: Icons.shopping_bag_outlined, onTap: () {}, isDark: isDark),
            if (cart.itemCount > 0)
              Positioned(
                top: -4, right: -4,
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: Center(child: Text(
                    '${cart.itemCount > 9 ? '9+' : cart.itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                  )),
                ),
              ),
          ])),
        ]),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _IconButton({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Icon(icon, size: 20, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
    ),
  );
}
