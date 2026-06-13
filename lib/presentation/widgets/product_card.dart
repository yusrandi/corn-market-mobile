import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const ProductCard({super.key, required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf   = isDark ? AppColors.darkSurface : AppColors.surface;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final txtSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final txtHnt = isDark ? AppColors.darkTextHint : AppColors.textHint;

    return Container(
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppConstants.radiusLG),
              topRight: Radius.circular(AppConstants.radiusLG),
            ),
            child: SizedBox(
              height: 130, width: double.infinity,
              child: Image.network(
                product.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primaryLight,
                  child: const Center(child: Text('🌽', style: TextStyle(fontSize: 40))),
                ),
                loadingBuilder: (_, child, loading) {
                  if (loading == null) return child;
                  return Container(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 8, left: 8,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (product.isPopular) _Badge(label: '🔥 Populer', isPopular: true),
              if (product.isNew) ...[
                if (product.isPopular) const SizedBox(height: 4),
                _Badge(label: '✨ Baru', isPopular: false),
              ],
            ]),
          ),
        ]),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: AppTextStyles.titleMedium.copyWith(color: txtPri), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
              const SizedBox(width: 2),
              Text(product.rating.toStringAsFixed(1), style: AppTextStyles.labelLarge.copyWith(color: txtSec, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Text('(${product.reviewCount})', style: AppTextStyles.labelLarge.copyWith(color: txtHnt)),
            ]),
            const SizedBox(height: 4),
            // Live stock indicator
            if (product.stock < 20)
              Row(children: [
                Container(width: 6, height: 6,
                  decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('Stok tersisa \${product.stock}', style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.warning, fontWeight: FontWeight.w600)),
              ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(CurrencyFormatter.format(product.price), style: AppTextStyles.priceStyle),
                Text('/ ${product.unit}', style: AppTextStyles.labelLarge.copyWith(color: txtHnt)),
              ]),
              GestureDetector(
                onTap: onAddToCart,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: const Icon(Icons.add_rounded, color: AppColors.textPrimary, size: 20),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool isPopular;
  const _Badge({required this.label, required this.isPopular});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isPopular ? AppColors.primary : AppColors.secondaryLight,
      borderRadius: BorderRadius.circular(AppConstants.radiusSM),
    ),
    child: Text(label, style: AppTextStyles.labelLarge.copyWith(
      color: isPopular ? AppColors.textPrimary : Colors.white,
      fontSize: 10, fontWeight: FontWeight.w600,
    )),
  );
}
