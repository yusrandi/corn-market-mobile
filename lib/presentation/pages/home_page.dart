import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/home_controller.dart';
import '../controllers/cart_controller.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/banner_slider.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stats_banner.dart';
import '../widgets/animations/animation_widgets.dart';
import '../widgets/shimmer/shimmer_product_card.dart';
import '../widgets/shimmer/shimmer_misc.dart';
import '../widgets/shimmer/shimmer_box.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: const HomeAppBar(),
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    final cart = Get.find<CartController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      // ── Full shimmer skeleton while loading ──────────────────────────────
      if (ctrl.isLoading.value) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.spacingMD),
              const ShimmerBanner(),
              const SizedBox(height: AppConstants.spacingLG),
              // stats placeholder
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding),
                child: ShimmerBox(
                    width: double.infinity,
                    height: 80,
                    borderRadius: AppConstants.radiusLG),
              ),
              const SizedBox(height: AppConstants.spacingLG),
              const ShimmerSectionHeader(),
              const SizedBox(height: AppConstants.spacingMD),
              const ShimmerProductRow(),
              const SizedBox(height: AppConstants.spacingLG),
              const ShimmerSectionHeader(),
              const SizedBox(height: AppConstants.spacingMD),
              const ShimmerCategoryTabs(),
              const SizedBox(height: AppConstants.spacingMD),
              const ShimmerProductGrid(count: 4),
              const SizedBox(height: AppConstants.spacingXL),
            ],
          ),
        );
      }

      // ── Loaded content ───────────────────────────────────────────────────
      return RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        onRefresh: ctrl.refresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingMD)),

            SliverToBoxAdapter(child: SearchBarWidget()),

            // Banner
            SliverToBoxAdapter(
              child: SlideInWidget(
                delay: const Duration(milliseconds: 50),
                beginOffset: const Offset(0, 0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.horizontalPadding),
                  child: BannerSlider(),
                ),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingLG)),

            // Stats
            SliverToBoxAdapter(
              child: SlideInWidget(
                delay: const Duration(milliseconds: 120),
                child: const StatsBanner(),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingLG)),

            // Popular header
            SliverToBoxAdapter(
              child: FadeInWidget(
                delay: const Duration(milliseconds: 180),
                child: const SectionHeader(
                  title: '🔥 Produk Populer',
                  subtitle: 'Paling banyak dipesan minggu ini',
                  actionLabel: 'Lihat Semua',
                ),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingMD)),

            // Popular row
            SliverToBoxAdapter(
              child: FadeInWidget(
                delay: const Duration(milliseconds: 220),
                child: SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding),
                    itemCount: ctrl.popularProducts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppConstants.spacingMD),
                    itemBuilder: (_, i) {
                      final p = ctrl.popularProducts[i];
                      return SizedBox(
                        width: 160,
                        child: TapBounce(
                          onTap: () =>
                              Get.toNamed(AppRoutes.detail, arguments: p),
                          child: ProductCard(
                              product: p, onAddToCart: () => cart.addItem(p)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingLG)),

            // All products header
            SliverToBoxAdapter(
              child: FadeInWidget(
                delay: const Duration(milliseconds: 260),
                child: const SectionHeader(
                  title: '🌽 Semua Produk',
                  subtitle: 'Pilih kategori yang kamu mau',
                ),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingMD)),

            SliverToBoxAdapter(
              child: FadeInWidget(
                delay: const Duration(milliseconds: 300),
                child: const CategoryTabs(),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingMD)),

            // Product grid
            Obx(() {
              final products = ctrl.displayedProducts;
              if (products.isEmpty) {
                return SliverToBoxAdapter(
                  child: ScaleInWidget(
                    beginScale: 0.85,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingXXL),
                      child: Column(children: [
                        const Text('🌽', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: AppConstants.spacingMD),
                        Text('Produk tidak ditemukan',
                            style: AppTextStyles.headlineMedium),
                        const SizedBox(height: AppConstants.spacingSM),
                        Text('Coba kata kunci lain',
                            style: AppTextStyles.bodyMedium),
                      ]),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => SlideInWidget(
                      delay: Duration(milliseconds: 60 * (i % 4)),
                      beginOffset: const Offset(0, 0.1),
                      child: TapBounce(
                        onTap: () => Get.toNamed(AppRoutes.detail,
                            arguments: products[i]),
                        child: ProductCard(
                          product: products[i],
                          onAddToCart: () => cart.addItem(products[i]),
                        ),
                      ),
                    ),
                    childCount: products.length,
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingXL)),
          ],
        ),
      );
    });
  }
}
