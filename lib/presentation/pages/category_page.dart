import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../widgets/animations/animation_widgets.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/product_repository.dart';
import '../controllers/cart_controller.dart';
import '../widgets/common/corn_app_bar.dart';
import '../widgets/product_card.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCat = Rx<CategoryModel>(ProductRepository.categories[0]);
    final sortIndex = 0.obs;
    final minPrice = 0.0.obs;
    final maxPrice = 200000.0.obs;
    final cart = Get.find<CartController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final surf = isDark ? AppColors.darkSurface : AppColors.surface;

    final sortOptions = [
      'Terbaru',
      'Harga Terendah',
      'Harga Tertinggi',
      'Rating Terbaik'
    ];

    RxList<ProductModel> filtered() {
      var list = selectedCat.value.id == 'all'
          ? List<ProductModel>.from(ProductRepository.products)
          : ProductRepository.products
              .where((p) => p.category == selectedCat.value.id)
              .toList();

      list = list
          .where((p) => p.price >= minPrice.value && p.price <= maxPrice.value)
          .toList();

      switch (sortIndex.value) {
        case 1:
          list.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 2:
          list.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 3:
          list.sort((a, b) => b.rating.compareTo(a.rating));
          break;
      }
      return list.obs;
    }

    return Scaffold(
      appBar: CornAppBar(
        title: 'Kategori',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 22),
            onPressed: () => _showFilterSheet(
                context, minPrice, maxPrice, sortIndex, sortOptions, isDark),
          ),
        ],
      ),
      body: Column(children: [
        // Category horizontal list
        Container(
          color: isDark ? AppColors.darkBackground : AppColors.background,
          child: SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding, vertical: 12),
              itemCount: ProductRepository.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final cat = ProductRepository.categories[i];
                return Obx(() {
                  final sel = selectedCat.value.id == cat.id;
                  return GestureDetector(
                    onTap: () => selectedCat.value = cat,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 78,
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : surf,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLG),
                        boxShadow: [
                          BoxShadow(
                              color: sel
                                  ? AppColors.primary.withOpacity(0.3)
                                  : AppColors.cardShadow,
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat.emoji,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text(cat.name,
                                style: AppTextStyles.labelLarge.copyWith(
                                    color: sel
                                        ? AppColors.textPrimary
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary),
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w500)),
                          ]),
                    ),
                  );
                });
              },
            ),
          ),
        ),

        // Sort chips
        Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding, vertical: 8),
              child: Row(
                  children: List.generate(sortOptions.length, (i) {
                final sel = sortIndex.value == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => sortIndex.value = i,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.secondary : surf,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(color: AppColors.cardShadow, blurRadius: 4)
                        ],
                      ),
                      child: Text(sortOptions[i],
                          style: AppTextStyles.labelLarge.copyWith(
                              color: sel
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.w500)),
                    ),
                  ),
                );
              })),
            )),

        // Product grid
        Expanded(
          child: Obx(() {
            final list = filtered();
            if (list.isEmpty) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🌽', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text('Tidak ada produk',
                      style:
                          AppTextStyles.headlineMedium.copyWith(color: txtPri)),
                  Text('Coba filter lain', style: AppTextStyles.bodyMedium),
                ]),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) => SlideInWidget(
                delay: Duration(milliseconds: 50 * (i % 4)),
                beginOffset: const Offset(0, 0.08),
                child: TapBounce(
                  onTap: () =>
                      Get.toNamed(AppRoutes.detail, arguments: list[i]),
                  child: ProductCard(
                      product: list[i],
                      onAddToCart: () => cart.addItem(list[i])),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }

  void _showFilterSheet(BuildContext context, RxDouble minPrice,
      RxDouble maxPrice, RxInt sortIndex, List<String> sorts, bool isDark) {
    final surf = isDark ? AppColors.darkSurface : AppColors.surface;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surf,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Filter & Urutkan',
                    style:
                        AppTextStyles.headlineMedium.copyWith(color: txtPri)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: Get.back),
              ]),
              const SizedBox(height: 16),
              Text('Rentang Harga',
                  style: AppTextStyles.titleMedium.copyWith(color: txtPri)),
              const SizedBox(height: 8),
              Obx(() => RangeSlider(
                    values: RangeValues(minPrice.value, maxPrice.value),
                    min: 0,
                    max: 200000,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primaryLight,
                    labels: RangeLabels(
                      'Rp ${(minPrice.value / 1000).toInt()}rb',
                      'Rp ${(maxPrice.value / 1000).toInt()}rb',
                    ),
                    onChanged: (r) {
                      minPrice.value = r.start;
                      maxPrice.value = r.end;
                    },
                  )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: Get.back,
                  child: const Text('Terapkan Filter'),
                ),
              ),
              const SizedBox(height: 8),
            ]),
      ),
      isScrollControlled: true,
    );
  }
}
