import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> items = <CartItemModel>[].obs;
  final RxString selectedPayment = 'Transfer Bank BCA'.obs;
  final RxString selectedAddress = 'Jl. Soekarno Hatta No. 12, Balikpapan Selatan'.obs;
  final RxBool freeShipping = false.obs;

  static const double shippingFee = 15000;
  static const double freeShippingThreshold = 100000;

  int get itemCount => items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal => items.fold(0.0, (sum, e) => sum + e.subtotal);

  double get shipping {
    if (subtotal >= freeShippingThreshold) return 0;
    return shippingFee;
  }

  double get total => subtotal + shipping;

  bool get isEmpty => items.isEmpty;

  void addItem(ProductModel product, {int quantity = 1}) {
    final idx = items.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + quantity);
    } else {
      items.add(CartItemModel(product: product, quantity: quantity));
    }
    items.refresh();
    Get.snackbar(
      'Ditambahkan 🌽',
      '${product.name} berhasil masuk keranjang',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void increment(String productId) {
    final idx = items.indexWhere((e) => e.product.id == productId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
      items.refresh();
    }
  }

  void decrement(String productId) {
    final idx = items.indexWhere((e) => e.product.id == productId);
    if (idx >= 0) {
      if (items[idx].quantity <= 1) {
        removeItem(productId);
      } else {
        items[idx] = items[idx].copyWith(quantity: items[idx].quantity - 1);
        items.refresh();
      }
    }
  }

  void removeItem(String productId) {
    items.removeWhere((e) => e.product.id == productId);
  }

  void clear() => items.clear();

  bool isInCart(String productId) => items.any((e) => e.product.id == productId);

  int quantityOf(String productId) {
    final item = items.firstWhereOrNull((e) => e.product.id == productId);
    return item?.quantity ?? 0;
  }
}
