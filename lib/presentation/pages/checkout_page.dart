import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/currency_formatter.dart';
import '../controllers/cart_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/common/corn_app_bar.dart';
import '../widgets/common/primary_button.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart   = Get.find<CartController>();
    final auth   = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf   = isDark ? AppColors.darkSurface : AppColors.surface;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final txtSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final paymentMethods = [
      ('Transfer Bank BCA', Icons.account_balance_outlined),
      ('Transfer Bank Mandiri', Icons.account_balance_outlined),
      ('QRIS / GoPay', Icons.qr_code_rounded),
      ('COD (Bayar di Tempat)', Icons.local_shipping_outlined),
    ];

    return Scaffold(
      appBar: const CornAppBar(title: 'Konfirmasi Pesanan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Alamat pengiriman
          _SectionCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionTitle('📍 Alamat Pengiriman', txtPri),
            const SizedBox(height: 12),
            Obx(() => Text(
              auth.currentUser.value?.name ?? 'User',
              style: AppTextStyles.titleMedium.copyWith(color: txtPri),
            )),
            Obx(() => Text(auth.currentUser.value?.phone ?? '', style: AppTextStyles.bodyMedium.copyWith(color: txtSec))),
            const SizedBox(height: 4),
            Obx(() => Text(
              cart.selectedAddress.value,
              style: AppTextStyles.bodyMedium.copyWith(color: txtSec),
            )),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _editAddress(cart),
              child: Text('Ubah Alamat', style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary)),
            ),
          ])),
          const SizedBox(height: 16),

          // Produk
          _SectionCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionTitle('🌽 Produk Dipesan', txtPri),
            const SizedBox(height: 12),
            ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(item.product.imageUrl, width: 52, height: 52, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 52, height: 52, color: AppColors.primaryLight,
                      child: const Center(child: Text('🌽'))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.product.name, style: AppTextStyles.titleMedium.copyWith(color: txtPri), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${item.quantity} ${item.product.unit}', style: AppTextStyles.bodyMedium.copyWith(color: txtSec)),
                ])),
                Text(CurrencyFormatter.format(item.subtotal), style: AppTextStyles.priceStyle),
              ]),
            )),
          ])),
          const SizedBox(height: 16),

          // Metode Pembayaran
          _SectionCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionTitle('💳 Metode Pembayaran', txtPri),
            const SizedBox(height: 12),
            ...paymentMethods.map((m) => Obx(() {
              final selected = cart.selectedPayment.value == m.$1;
              return GestureDetector(
                onTap: () => cart.selectedPayment.value = m.$1,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryLight : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 1.5),
                  ),
                  child: Row(children: [
                    Icon(m.$2, size: 20, color: selected ? AppColors.primaryDark : txtSec),
                    const SizedBox(width: 10),
                    Expanded(child: Text(m.$1, style: AppTextStyles.titleMedium.copyWith(color: selected ? AppColors.primaryDark : txtPri))),
                    if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryDark, size: 18),
                  ]),
                ),
              );
            })),
          ])),
          const SizedBox(height: 16),

          // Ringkasan biaya
          _SectionCard(isDark: isDark, child: Column(children: [
            _SectionTitle('📊 Ringkasan Biaya', txtPri),
            const SizedBox(height: 12),
            Obx(() => Column(children: [
              _Row('Subtotal', CurrencyFormatter.format(cart.subtotal), txtPri, txtSec),
              const SizedBox(height: 6),
              _Row('Ongkos Kirim', cart.shipping == 0 ? 'GRATIS' : CurrencyFormatter.format(cart.shipping),
                  cart.shipping == 0 ? AppColors.success : txtPri, txtSec),
              Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.divider),
              _Row('Total Pembayaran', CurrencyFormatter.format(cart.total), AppColors.secondary, txtSec, isBold: true),
            ])),
          ])),
          const SizedBox(height: 100),
        ]),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: surf,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total', style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
            Text(CurrencyFormatter.format(cart.total), style: AppTextStyles.priceLarge),
          ])),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Buat Pesanan',
            onPressed: () => _placeOrder(cart),
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
          ),
        ]),
      ),
    );
  }

  void _placeOrder(CartController cart) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: Text('Total: ${CurrencyFormatter.format(cart.total)}\nLanjutkan pembayaran?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cek Lagi')),
          ElevatedButton(
            onPressed: () {
              cart.clear();
              Get.back();
              Get.offAllNamed(AppRoutes.orderSuccess);
            },
            child: const Text('Ya, Pesan!'),
          ),
        ],
      ),
    );
  }

  void _editAddress(CartController cart) {
    final ctrl = TextEditingController(text: cart.selectedAddress.value);
    Get.dialog(AlertDialog(
      title: const Text('Ubah Alamat'),
      content: TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Masukkan alamat lengkap')),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Batal')),
        ElevatedButton(onPressed: () { cart.selectedAddress.value = ctrl.text; Get.back(); }, child: const Text('Simpan')),
      ],
    ));
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SectionCard({required this.child, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );
}

Widget _SectionTitle(String text, Color color) => Text(text, style: AppTextStyles.titleLarge.copyWith(color: color));

class _Row extends StatelessWidget {
  final String label, value;
  final Color valueColor, labelColor;
  final bool isBold;
  const _Row(this.label, this.value, this.valueColor, this.labelColor, {this.isBold = false});
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: AppTextStyles.bodyMedium.copyWith(color: labelColor)),
    const Spacer(),
    Text(value, style: isBold
        ? AppTextStyles.headlineMedium.copyWith(color: valueColor)
        : AppTextStyles.titleMedium.copyWith(color: valueColor)),
  ]);
}
