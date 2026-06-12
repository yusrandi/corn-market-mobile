import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import 'shimmer_box.dart';

/// Banner slider skeleton
class ShimmerBanner extends StatelessWidget {
  const ShimmerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      child: ShimmerBox(
        width: double.infinity,
        height: 170,
        borderRadius: AppConstants.radiusXL,
      ),
    );
  }
}

/// Category tabs skeleton
class ShimmerCategoryTabs extends StatelessWidget {
  const ShimmerCategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, __) => ShimmerBox(
          width: 84,
          height: 40,
          borderRadius: AppConstants.radiusRound,
        ),
      ),
    );
  }
}

/// Section header skeleton
class ShimmerSectionHeader extends StatelessWidget {
  const ShimmerSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      child: Row(
        children: [
          ShimmerBox(width: 160, height: 18, borderRadius: 6),
          const Spacer(),
          ShimmerBox(width: 64, height: 26, borderRadius: AppConstants.radiusRound),
        ],
      ),
    );
  }
}

/// Cart item skeleton
class ShimmerCartItem extends StatelessWidget {
  const ShimmerCartItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerBox(width: 80, height: 80, borderRadius: AppConstants.radiusMD),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: double.infinity, height: 14, borderRadius: 5),
              const SizedBox(height: 6),
              ShimmerBox(width: 100, height: 11, borderRadius: 5),
              const SizedBox(height: 10),
              Row(
                children: [
                  ShimmerBox(width: 60, height: 14, borderRadius: 5),
                  const Spacer(),
                  ShimmerBox(width: 96, height: 28, borderRadius: 7),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Order card skeleton
class ShimmerOrderCard extends StatelessWidget {
  const ShimmerOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShimmerBox(width: 120, height: 14, borderRadius: 5),
            const Spacer(),
            ShimmerBox(width: 80, height: 24, borderRadius: 100),
          ],
        ),
        const SizedBox(height: 8),
        ShimmerBox(width: 100, height: 11, borderRadius: 4),
        const SizedBox(height: 12),
        Row(
          children: [
            ShimmerBox(width: 44, height: 44, borderRadius: 8),
            const SizedBox(width: 10),
            ShimmerBox(width: 140, height: 14, borderRadius: 5),
          ],
        ),
      ],
    );
  }
}
