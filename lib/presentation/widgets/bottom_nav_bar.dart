import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt selectedIndex = 0.obs;

    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Beranda'),
      (Icons.category_rounded, Icons.category_outlined, 'Kategori'),
      (Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 'Keranjang'),
      (Icons.favorite_rounded, Icons.favorite_outline_rounded, 'Favorit'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = selectedIndex.value == index;
                  return GestureDetector(
                    onTap: () => selectedIndex.value = index,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMD),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.$1 : item.$2,
                            size: 24,
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.textHint,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.$3,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.textHint,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              )),
        ),
      ),
    );
  }
}
