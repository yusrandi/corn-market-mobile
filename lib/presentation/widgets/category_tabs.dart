import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/home_controller.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding,
        ),
        itemCount: ctrl.categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppConstants.spacingSM),
        itemBuilder: (_, index) {
          return Obx(() {
            final isSelected = ctrl.selectedCategoryIndex.value == index;
            final category = ctrl.categories[index];
            return GestureDetector(
              onTap: () => ctrl.selectCategory(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusRound),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
