import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/bank_constants.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/interfaces/repository_interfaces.dart';
import '../controllers/auth_controller.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> items          = <CartItemModel>[].obs;
  final RxString selectedAddress             = 'Jl. Soekarno Hatta No. 12, Balikpapan'.obs;
  final Rx<BankInfo?> selectedBank           = Rx<BankInfo?>(BankConstants.banks.first);
  final RxBool   isPlacingOrder              = false.obs;

  static const double shippingFee           = 15000;
  static const double freeShippingThreshold = 100000;

  int    get itemCount => items.fold(0, (s, e) => s + e.quantity);
  double get subtotal  => items.fold(0.0, (s, e) => s + e.subtotal);
  double get shipping  => subtotal >= freeShippingThreshold ? 0 : shippingFee;
  double get total     => subtotal + shipping;
  bool   get isEmpty   => items.isEmpty;

  // ── Cart operations ───────────────────────────────────────

  void addItem(ProductModel product, {int quantity = 1}) {
    final idx = items.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + quantity);
    } else {
      items.add(CartItemModel(product: product, quantity: quantity));
    }
    items.refresh();
    Get.snackbar(
      'Ditambahkan 🌽', '${product.name} berhasil masuk keranjang',
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

  void removeItem(String productId) =>
      items.removeWhere((e) => e.product.id == productId);

  void clear() => items.clear();

  bool isInCart(String productId) =>
      items.any((e) => e.product.id == productId);

  int quantityOf(String productId) =>
      items.firstWhereOrNull((e) => e.product.id == productId)?.quantity ?? 0;

  void selectBank(BankInfo bank) => selectedBank.value = bank;

  // ── Place order via Supabase ──────────────────────────────

  Future<void> placeOrder() async {
    if (items.isEmpty) return;
    final auth   = Get.find<AuthController>();
    final userId = auth.currentUser.value?.id ?? '';
    if (userId.isEmpty) {
      Get.snackbar('Error', 'Silakan login terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedBank.value == null) {
      Get.snackbar('Pilih Bank', 'Pilih bank tujuan transfer dulu',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isPlacingOrder.value = true;
    try {
      final orderRepo = Get.find<IOrderRepository>();
      final bank = selectedBank.value!;
      await orderRepo.createOrder(
        userId:        userId,
        items:         items.toList(),
        subtotal:      subtotal,
        shippingFee:   shipping,
        total:         total,
        address:       selectedAddress.value,
        paymentMethod: 'Transfer Bank ${bank.name}',
        bankName:      bank.name,
        bankAccount:   bank.accountNumber,
        bankHolder:    bank.accountHolder,
      );
      clear();
      Get.offAllNamed(AppRoutes.orderSuccess);
    } catch (e) {
      Get.snackbar('Gagal 😢', 'Pesanan gagal dibuat. Coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
