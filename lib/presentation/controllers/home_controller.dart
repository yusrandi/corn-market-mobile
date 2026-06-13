import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/banner_model.dart';
import '../../data/repositories/interfaces/repository_interfaces.dart';

class HomeController extends GetxController {
  final IProductRepository productRepo;
  HomeController({required this.productRepo});

  // State
  final RxInt    selectedCategoryIndex = 0.obs;
  final RxInt    currentBannerIndex    = 0.obs;
  final RxBool   isSearchActive        = false.obs;
  final RxString searchQuery           = ''.obs;
  final RxBool   isLoading             = true.obs;
  final RxBool   isRefreshing          = false.obs;
  final RxString errorMessage          = ''.obs;

  // Data
  final RxList<CategoryModel> categories      = <CategoryModel>[].obs;
  final RxList<BannerModel>   banners         = <BannerModel>[].obs;
  final RxList<ProductModel>  popularProducts = <ProductModel>[].obs;
  final RxList<ProductModel>  newProducts     = <ProductModel>[].obs;
  final RxList<ProductModel>  displayedProducts = <ProductModel>[].obs;

  // Realtime subscription
  StreamSubscription<List<ProductModel>>? _realtimeSub;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    _realtimeSub?.cancel();
    super.onClose();
  }

  // ── Load all data ─────────────────────────────────────────

  Future<void> loadAll() async {
    isLoading.value  = true;
    errorMessage.value = '';
    try {
      // Parallel fetch
      final results = await Future.wait([
        productRepo.getCategories(),
        productRepo.getBanners(),
        productRepo.getPopularProducts(),
        productRepo.getNewProducts(),
        productRepo.getProducts(),
      ]);

      categories.assignAll(results[0] as List<CategoryModel>);
      banners.assignAll(results[1] as List<BannerModel>);
      popularProducts.assignAll(results[2] as List<ProductModel>);
      newProducts.assignAll(results[3] as List<ProductModel>);
      displayedProducts.assignAll(results[4] as List<ProductModel>);

      // Start realtime listener after initial load
      _startRealtimeListener();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data. Periksa koneksi internet.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Realtime: watch product stock changes ─────────────────

  void _startRealtimeListener() {
    _realtimeSub?.cancel();
    final slug = selectedCategory.id == 'all' ? null : selectedCategory.id;
    _realtimeSub = productRepo.watchProducts(categorySlug: slug).listen(
      (products) {
        // Update displayed list in-place (preserves scroll position)
        for (final updated in products) {
          final idx = displayedProducts.indexWhere((p) => p.id == updated.id);
          if (idx >= 0) {
            displayedProducts[idx] = updated;
            displayedProducts.refresh();
          }
        }
        // Also update popular list
        for (final updated in products) {
          final idx = popularProducts.indexWhere((p) => p.id == updated.id);
          if (idx >= 0) {
            popularProducts[idx] = updated;
            popularProducts.refresh();
          }
        }
      },
      onError: (_) {}, // silently ignore realtime errors
    );
  }

  // ── Pull to refresh ───────────────────────────────────────

  Future<void> refresh() async {
    isRefreshing.value = true;
    try {
      final products = await productRepo.getProducts(
        categorySlug: selectedCategory.id == 'all' ? null : selectedCategory.id,
      );
      displayedProducts.assignAll(products);

      final popular = await productRepo.getPopularProducts();
      popularProducts.assignAll(popular);
    } catch (_) {}
    isRefreshing.value = false;
  }

  // ── Category filter ───────────────────────────────────────

  Future<void> selectCategory(int index) async {
    selectedCategoryIndex.value = index;
    _realtimeSub?.cancel();

    if (searchQuery.value.isNotEmpty) return; // search takes priority

    isLoading.value = true;
    try {
      final slug = categories[index].id == 'all' ? null : categories[index].id;
      final products = await productRepo.getProducts(categorySlug: slug);
      displayedProducts.assignAll(products);
      _startRealtimeListener();
    } catch (_) {}
    isLoading.value = false;
  }

  // ── Search ────────────────────────────────────────────────

  Future<void> onSearchChanged(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      selectCategory(selectedCategoryIndex.value);
      return;
    }
    try {
      final results = await productRepo.getProducts(query: query);
      displayedProducts.assignAll(results);
    } catch (_) {}
  }

  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) {
      searchQuery.value = '';
      selectCategory(selectedCategoryIndex.value);
    }
  }

  // ── Banner ────────────────────────────────────────────────

  void updateBannerIndex(int index) => currentBannerIndex.value = index;

  // ── Helpers ───────────────────────────────────────────────

  CategoryModel get selectedCategory =>
      categories.isNotEmpty ? categories[selectedCategoryIndex.value] : const CategoryModel(id: 'all', name: 'Semua', emoji: '🌽', description: '');
}
