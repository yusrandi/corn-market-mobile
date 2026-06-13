import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/bank_constants.dart';
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

    return Scaffold(
      appBar: const CornAppBar(title: 'Konfirmasi Pesanan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Alamat ──────────────────────────────────────
          _SectionCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Title('📍 Alamat Pengiriman', txtPri),
            const SizedBox(height: 12),
            Obx(() => Text(auth.currentUser.value?.name ?? 'Pengguna',
                style: AppTextStyles.titleMedium.copyWith(color: txtPri))),
            Obx(() => Text(auth.currentUser.value?.phone ?? '',
                style: AppTextStyles.bodyMedium.copyWith(color: txtSec))),
            const SizedBox(height: 4),
            Obx(() => Text(cart.selectedAddress.value,
                style: AppTextStyles.bodyMedium.copyWith(color: txtSec))),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _editAddress(cart),
              child: Text('Ubah Alamat',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary)),
            ),
          ])),
          const SizedBox(height: 14),

          // ── Produk ───────────────────────────────────────
          _SectionCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Title('🌽 Produk Dipesan', txtPri),
            const SizedBox(height: 12),
            ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(item.product.imageUrl, width: 52, height: 52, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 52, height: 52,
                      color: AppColors.primaryLight, child: const Center(child: Text('🌽'))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.product.name, style: AppTextStyles.titleMedium.copyWith(color: txtPri),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${item.quantity} ${item.product.unit}',
                      style: AppTextStyles.bodyMedium.copyWith(color: txtSec)),
                ])),
                Text(CurrencyFormatter.format(item.subtotal), style: AppTextStyles.priceStyle),
              ]),
            )),
          ])),
          const SizedBox(height: 14),

          // ── Pilih Bank Transfer ───────────────────────────
          _SectionCard(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Title('🏦 Pilih Bank Tujuan Transfer', txtPri),
            const SizedBox(height: 4),
            Text('Setelah memesan, transfer ke rekening yang dipilih',
                style: AppTextStyles.bodyMedium.copyWith(color: txtSec)),
            const SizedBox(height: 14),
            ...BankConstants.banks.map((bank) => Obx(() {
              final selected = cart.selectedBank.value?.code == bank.code;
              return GestureDetector(
                onTap: () => cart.selectBank(bank),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryLight : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(children: [
                    // Bank radio
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color: selected ? AppColors.primaryDark : (isDark ? AppColors.darkTextHint : AppColors.textHint),
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check, size: 12, color: AppColors.textPrimary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(bank.name,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: selected ? AppColors.primaryDark : txtPri,
                          )),
                      Text('${bank.accountNumber}  •  ${bank.accountHolder}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: selected ? AppColors.primaryDark.withOpacity(0.7) : txtSec,
                          )),
                    ])),
                    if (selected)
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: bank.accountNumber));
                          Get.snackbar('Disalin! 📋', 'Nomor rekening disalin',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Salin',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ]),
                ),
              );
            })),
          ])),
          const SizedBox(height: 14),

          // ── Transfer Info ─────────────────────────────────
          Obx(() {
            final bank = cart.selectedBank.value;
            if (bank == null) return const SizedBox.shrink();
            return _SectionCard(
              isDark: isDark,
              color: AppColors.secondaryPale,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('📋', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text('Instruksi Transfer', style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondary)),
                ]),
                const SizedBox(height: 10),
                _InfoRow('Bank',    bank.name,                 AppColors.secondary),
                _InfoRow('Rek.',    bank.accountNumber,        AppColors.secondary),
                _InfoRow('A.N.',    bank.accountHolder,        AppColors.secondary),
                _InfoRow('Nominal', CurrencyFormatter.format(cart.total), AppColors.secondary, bold: true),
                const SizedBox(height: 8),
                Text('⚠️ Transfer tepat sesuai nominal agar verifikasi lebih cepat.',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary)),
              ]),
            );
          }),
          const SizedBox(height: 14),

          // ── Ringkasan Biaya ───────────────────────────────
          _SectionCard(isDark: isDark, child: Column(children: [
            _Title('📊 Ringkasan Biaya', txtPri),
            const SizedBox(height: 12),
            Obx(() => Column(children: [
              _SummaryRow('Subtotal', CurrencyFormatter.format(cart.subtotal), txtPri, txtSec),
              const SizedBox(height: 6),
              _SummaryRow('Ongkos Kirim',
                  cart.shipping == 0 ? 'GRATIS' : CurrencyFormatter.format(cart.shipping),
                  cart.shipping == 0 ? AppColors.success : txtPri, txtSec),
              Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.divider),
              _SummaryRow('Total', CurrencyFormatter.format(cart.total), AppColors.secondary, txtSec, isBold: true),
            ])),
          ])),
          const SizedBox(height: 100),
        ]),
      ),

      // ── Bottom Bar ────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: surf,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total', style: AppTextStyles.bodyMedium.copyWith(color: txtSec)),
            Text(CurrencyFormatter.format(cart.total), style: AppTextStyles.priceLarge),
          ])),
          const SizedBox(height: 10),
          Obx(() => PrimaryButton(
            label: 'Buat Pesanan',
            isLoading: cart.isPlacingOrder.value,
            onPressed: () => _confirmOrder(cart),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          )),
        ]),
      ),
    );
  }

  void _confirmOrder(CartController cart) {
    final bank = cart.selectedBank.value;
    if (bank == null) {
      Get.snackbar('Pilih Bank', 'Pilih bank tujuan transfer terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return;
    }
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Konfirmasi Pesanan'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Total yang harus ditransfer:'),
        const SizedBox(height: 4),
        Text(CurrencyFormatter.format(cart.total),
            style: AppTextStyles.headlineLarge.copyWith(color: AppColors.secondary)),
        const SizedBox(height: 8),
        Text('ke ${bank.name}\n${bank.accountNumber}',
            style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Setelah memesan, upload bukti transfer di halaman detail pesanan.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark)),
        ),
      ]),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cek Lagi')),
        Obx(() => ElevatedButton(
          onPressed: cart.isPlacingOrder.value ? null : () { Get.back(); cart.placeOrder(); },
          child: cart.isPlacingOrder.value
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Ya, Pesan!'),
        )),
      ],
    ));
  }

  void _editAddress(CartController cart) {
    final ctrl = TextEditingController(text: cart.selectedAddress.value);
    Get.dialog(AlertDialog(
      title: const Text('Ubah Alamat'),
      content: TextField(controller: ctrl, maxLines: 3,
          decoration: const InputDecoration(hintText: 'Masukkan alamat lengkap')),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Batal')),
        ElevatedButton(
          onPressed: () { cart.selectedAddress.value = ctrl.text; Get.back(); },
          child: const Text('Simpan'),
        ),
      ],
    ));
  }
}

// ── Helpers ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color? color;
  const _SectionCard({required this.child, required this.isDark, this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color ?? (isDark ? AppColors.darkSurface : AppColors.surface),
      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      boxShadow: color == null
          ? [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))]
          : null,
    ),
    child: child,
  );
}

Widget _Title(String text, Color color) =>
    Text(text, style: AppTextStyles.titleLarge.copyWith(color: color));

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool bold;
  const _InfoRow(this.label, this.value, this.color, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      SizedBox(width: 60,
          child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color.withOpacity(0.7)))),
      Text(': ', style: AppTextStyles.bodyMedium),
      Expanded(child: Text(value, style: bold
          ? AppTextStyles.titleLarge.copyWith(color: color)
          : AppTextStyles.titleMedium.copyWith(color: color))),
    ]),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color valueColor, labelColor;
  final bool isBold;
  const _SummaryRow(this.label, this.value, this.valueColor, this.labelColor, {this.isBold = false});
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: AppTextStyles.bodyMedium.copyWith(color: labelColor)),
    const Spacer(),
    Text(value, style: isBold
        ? AppTextStyles.headlineMedium.copyWith(color: valueColor)
        : AppTextStyles.titleMedium.copyWith(color: valueColor)),
  ]);
}
