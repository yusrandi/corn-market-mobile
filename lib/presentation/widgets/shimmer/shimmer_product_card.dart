import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import 'shimmer_box.dart';

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf = isDark ? AppColors.darkSurface : AppColors.surface;

    return Container(
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          ShimmerBox(
            width: double.infinity,
            height: 130,
            borderRadius: AppConstants.radiusLG,
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
                const SizedBox(height: 8),
                ShimmerBox(width: 80, height: 11, borderRadius: 5),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 72, height: 14, borderRadius: 5),
                        const SizedBox(height: 4),
                        ShimmerBox(width: 40, height: 10, borderRadius: 4),
                      ],
                    ),
                    ShimmerBox(width: 34, height: 34, borderRadius: AppConstants.radiusSM),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid 2 kolom skeleton – pakai ini di HomePage/CategoryPage saat loading
class ShimmerProductGrid extends StatelessWidget {
  final int count;
  const ShimmerProductGrid({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const ShimmerProductCard(),
    );
  }
}

/// Horizontal row skeleton – pakai di Produk Populer saat loading
class ShimmerProductRow extends StatelessWidget {
  final int count;
  const ShimmerProductRow({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => const SizedBox(
          width: 160,
          child: ShimmerProductCard(),
        ),
      ),
    );
  }
}
