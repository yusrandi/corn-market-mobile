import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/cart_item_model.dart';
import '../controllers/cart_controller.dart';
import '../controllers/main_controller.dart';
import '../widgets/common/corn_app_bar.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/empty_state_widget.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart   = Get.find<CartController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf   = isDark ? AppColors.darkSurface : AppColors.surface;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final txtSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: CornAppBar(
        title: 'Keranjang Belanja',
        showBack: false,
        actions: [
          Obx(() => cart.isEmpty
              ? const SizedBox()
              : TextButton(
                  onPressed: () => _confirmClear(cart),
                  child: Text('Kosongkan',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
                )),
        ],
      ),
      body: Obx(() {
        if (cart.isEmpty) {
          return EmptyStateWidget(
            emoji: '🛒',
            title: 'Keranjang Kosong',
            subtitle: 'Yuk, pilih jagung segar\nfavorit kamu dulu!',
            buttonLabel: 'Mulai Belanja',
            onButton: () => Get.find<MainController>().changePage(0),
          );
        }
        return Column(children: [
          Obx(() {
            final remaining = CartController.freeShippingThreshold - cart.subtotal;
            if (remaining <= 0) {
              return _InfoBanner(
                icon: '🎉', text: 'Selamat! Kamu dapat gratis ongkir!',
                color: AppColors.secondaryPale, textColor: AppColors.secondary,
              );
            }
            return _InfoBanner(
              icon: '🚚',
              text: 'Belanja ${CurrencyFormatter.format(remaining)} lagi untuk gratis ongkir!',
              color: AppColors.primaryLight, textColor: AppColors.primaryDark,
            );
          }),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppConstants.horizontalPadding),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CartItemTile(
                item: cart.items[i], cart: cart,
                isDark: isDark, surf: surf, txtPri: txtPri, txtSec: txtSec,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: surf,
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, -4))],
            ),
            child: Column(children: [
              Obx(() => _SummaryRow('Subtotal (${cart.itemCount} item)',
                  CurrencyFormatter.format(cart.subtotal), isDark: isDark)),
              const SizedBox(height: 6),
              Obx(() => _SummaryRow(
                'Ongkir',
                cart.shipping == 0 ? 'GRATIS' : CurrencyFormatter.format(cart.shipping),
                valueColor: cart.shipping == 0 ? AppColors.success : null,
                isDark: isDark,
              )),
              Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.divider),
              Obx(() => _SummaryRow('Total', CurrencyFormatter.format(cart.total), isBold: true, isDark: isDark)),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Lanjut ke Pembayaran',
                onPressed: () => Get.toNamed(AppRoutes.checkout),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              ),
            ]),
          ),
        ]);
      }),
    );
  }

  void _confirmClear(CartController cart) {
    Get.dialog(AlertDialog(
      title: const Text('Kosongkan Keranjang?'),
      content: const Text('Semua item akan dihapus dari keranjang.'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Batal')),
        TextButton(
          onPressed: () { cart.clear(); Get.back(); },
          child: const Text('Hapus Semua', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ));
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final CartController cart;
  final bool isDark;
  final Color surf, txtPri, txtSec;
  const _CartItemTile({required this.item, required this.cart, required this.isDark, required this.surf, required this.txtPri, required this.txtSec});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          child: Image.network(product.imageUrl, width: 80, height: 80, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: AppColors.primaryLight,
              child: const Center(child: Text('🌽', style: TextStyle(fontSize: 32)))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.name, style: AppTextStyles.titleMedium.copyWith(color: txtPri), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('${CurrencyFormatter.format(product.price)} / ${product.unit}',
              style: AppTextStyles.labelLarge.copyWith(color: txtSec)),
          const SizedBox(height: 8),
          Row(children: [
            Text(CurrencyFormatter.format(item.subtotal), style: AppTextStyles.priceStyle),
            const Spacer(),
            Obx(() {
              final cur = cart.quantityOf(product.id);
              return Row(children: [
                _SmallBtn(icon: Icons.remove, onTap: () => cart.decrement(product.id)),
                SizedBox(width: 34, child: Center(child: Text('$cur', style: AppTextStyles.titleMedium.copyWith(color: txtPri)))),
                _SmallBtn(icon: Icons.add, onTap: () => cart.increment(product.id)),
              ]);
            }),
          ]),
        ])),
      ]),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(7)),
      child: Icon(icon, size: 16, color: AppColors.primaryDark),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isBold, isDark;
  const _SummaryRow(this.label, this.value, {this.valueColor, this.isBold = false, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final sec   = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Row(children: [
      Text(label, style: isBold ? AppTextStyles.titleLarge.copyWith(color: color) : AppTextStyles.bodyMedium.copyWith(color: sec)),
      const Spacer(),
      Text(value, style: isBold
          ? AppTextStyles.headlineLarge.copyWith(color: AppColors.secondary)
          : AppTextStyles.titleMedium.copyWith(color: valueColor ?? color)),
    ]);
  }
}

class _InfoBanner extends StatelessWidget {
  final String icon, text;
  final Color color, textColor;
  const _InfoBanner({required this.icon, required this.text, required this.color, required this.textColor});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: textColor))),
    ]),
  );
}
