import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/banner_model.dart';
import '../../data/repositories/product_repository.dart';

class HomeController extends GetxController {
  final ProductRepository _repository = ProductRepository();

  final RxInt    selectedCategoryIndex = 0.obs;
  final RxInt    currentBannerIndex    = 0.obs;
  final RxBool   isSearchActive        = false.obs;
  final RxString searchQuery           = ''.obs;
  final RxBool   isLoading             = true.obs;   // ← shimmer flag
  final RxBool   isRefreshing          = false.obs;  // ← pull-to-refresh flag

  late List<CategoryModel> categories;
  late List<BannerModel>   banners;
  late List<ProductModel>  popularProducts;
  late List<ProductModel>  newProducts;

  RxList<ProductModel> displayedProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    // Simulate network delay so shimmer is visible
    await Future.delayed(const Duration(milliseconds: 1200));

    categories      = ProductRepository.categories;
    banners         = ProductRepository.banners;
    popularProducts = _repository.getPopularProducts();
    newProducts     = _repository.getNewProducts();
    displayedProducts.assignAll(_repository.getProducts());

    isLoading.value = false;
  }

  Future<void> refresh() async {
    isRefreshing.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    displayedProducts.assignAll(
      _repository.getProducts(
        category: categories[selectedCategoryIndex.value].id == 'all'
            ? null
            : categories[selectedCategoryIndex.value].id,
      ),
    );
    isRefreshing.value = false;
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    final category = categories[index];
    displayedProducts.assignAll(
      _repository.getProducts(
        category: category.id == 'all' ? null : category.id,
      ),
    );
  }

  void updateBannerIndex(int index) => currentBannerIndex.value = index;

  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) {
      searchQuery.value = '';
      displayedProducts.assignAll(_repository.getProducts());
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      selectCategory(selectedCategoryIndex.value);
    } else {
      displayedProducts.assignAll(_repository.searchProducts(query));
    }
  }
}
