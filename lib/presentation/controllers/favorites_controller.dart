import 'package:get/get.dart';
import '../../data/models/product_model.dart';

class FavoritesController extends GetxController {
  final RxList<ProductModel> favorites = <ProductModel>[].obs;

  bool isFavorite(String productId) => favorites.any((p) => p.id == productId);

  void toggle(ProductModel product) {
    if (isFavorite(product.id)) {
      favorites.removeWhere((p) => p.id == product.id);
    } else {
      favorites.add(product);
    }
  }
}
