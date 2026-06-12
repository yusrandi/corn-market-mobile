import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/home_controller.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Obx(() {
      if (!ctrl.isSearchActive.value) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.horizontalPadding,
          0,
          AppConstants.horizontalPadding,
          AppConstants.spacingMD,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMD),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  autofocus: true,
                  onChanged: ctrl.onSearchChanged,
                  style: AppTextStyles.titleMedium,
                  decoration: InputDecoration(
                    hintText: 'Cari jagung...',
                    hintStyle: AppTextStyles.bodyMedium,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSM),
            GestureDetector(
              onTap: ctrl.toggleSearch,
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Center(
                  child: Text(
                    'Batal',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
