import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../widgets/common/corn_app_bar.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order  = Get.arguments as OrderModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf   = isDark ? AppColors.darkSurface : AppColors.surface;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final txtSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: CornAppBar(
        title: order.orderNumber,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Tracking Timeline
          _Card(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('🚚 Status Pengiriman', style: AppTextStyles.titleLarge.copyWith(color: txtPri)),
            const SizedBox(height: 4),
            if (order.trackingNumber != null)
              Text('No. Resi: ${order.trackingNumber}',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary)),
            const SizedBox(height: 20),
            _TrackingTimeline(status: order.status, isDark: isDark),
          ])),
          const SizedBox(height: 16),

          // Delivery address
          _Card(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📍 Alamat Pengiriman', style: AppTextStyles.titleLarge.copyWith(color: txtPri)),
            const SizedBox(height: 10),
            Text(order.address, style: AppTextStyles.bodyLarge.copyWith(color: txtSec)),
          ])),
          const SizedBox(height: 16),

          // Products
          _Card(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('🌽 Detail Produk', style: AppTextStyles.titleLarge.copyWith(color: txtPri)),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(item.product.imageUrl, width: 56, height: 56, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.primaryLight,
                      child: const Center(child: Text('🌽'))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.product.name, style: AppTextStyles.titleMedium.copyWith(color: txtPri),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text('${CurrencyFormatter.format(item.product.price)} × ${item.quantity} ${item.product.unit}',
                      style: AppTextStyles.bodyMedium.copyWith(color: txtSec)),
                ])),
                Text(CurrencyFormatter.format(item.subtotal), style: AppTextStyles.priceStyle),
              ]),
            )),
          ])),
          const SizedBox(height: 16),

          // Payment summary
          _Card(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('💳 Ringkasan Pembayaran', style: AppTextStyles.titleLarge.copyWith(color: txtPri)),
            const SizedBox(height: 12),
            _Row('Subtotal', CurrencyFormatter.format(order.subtotal), txtPri, txtSec),
            const SizedBox(height: 6),
            _Row('Ongkos Kirim', order.shippingFee == 0 ? 'GRATIS' : CurrencyFormatter.format(order.shippingFee),
                order.shippingFee == 0 ? AppColors.success : txtPri, txtSec),
            const SizedBox(height: 6),
            _Row('Metode Bayar', order.paymentMethod, txtPri, txtSec),
            Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.divider),
            _Row('Total', CurrencyFormatter.format(order.total), AppColors.secondary, txtSec, isBold: true),
          ])),
          const SizedBox(height: 24),

          // CTA berdasarkan status
          if (order.status == OrderStatus.delivered)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.star_outline_rounded),
                label: const Text('Beri Ulasan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          if (order.status == OrderStatus.pending)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                label: const Text('Batalkan Pesanan', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  final OrderStatus status;
  final bool isDark;
  const _TrackingTimeline({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (OrderStatus.pending,    '⏳', 'Menunggu Konfirmasi', 'Pesanan kamu sudah masuk'),
      (OrderStatus.confirmed,  '✅', 'Dikonfirmasi',        'Penjual mengonfirmasi pesanan'),
      (OrderStatus.processing, '📦', 'Diproses',            'Jagung sedang disiapkan'),
      (OrderStatus.shipped,    '🚚', 'Dikirim',             'Dalam perjalanan ke lokasimu'),
      (OrderStatus.delivered,  '🎉', 'Selesai',             'Pesanan berhasil diterima'),
    ];

    final currentIdx = steps.indexWhere((s) => s.$1 == status);

    return Column(children: List.generate(steps.length, (i) {
      final step      = steps[i];
      final isDone    = i <= currentIdx;
      final isCurrent = i == currentIdx;
      final isLast    = i == steps.length - 1;

      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Timeline line + dot
          Column(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isDone ? AppColors.secondary : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
                shape: BoxShape.circle,
                border: isCurrent ? Border.all(color: AppColors.primary, width: 2) : null,
              ),
              child: Center(child: Text(step.$2, style: const TextStyle(fontSize: 16))),
            ),
            if (!isLast) Expanded(child: Container(
              width: 2,
              color: isDone ? AppColors.secondaryLight : (isDark ? AppColors.darkDivider : AppColors.divider),
            )),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(step.$3, style: AppTextStyles.titleMedium.copyWith(
                  color: isDone ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary) : (isDark ? AppColors.darkTextHint : AppColors.textHint),
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500)),
              Text(step.$4, style: AppTextStyles.bodyMedium.copyWith(
                  color: isDone ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary) : (isDark ? AppColors.darkTextHint : AppColors.textHint))),
            ]),
          )),
        ]),
      );
    }));
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});
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

class _Row extends StatelessWidget {
  final String label, value;
  final Color valColor, labColor;
  final bool isBold;
  const _Row(this.label, this.value, this.valColor, this.labColor, {this.isBold = false});
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: AppTextStyles.bodyMedium.copyWith(color: labColor)),
    const Spacer(),
    Text(value, style: isBold
        ? AppTextStyles.headlineMedium.copyWith(color: valColor)
        : AppTextStyles.titleMedium.copyWith(color: valColor)),
  ]);
}
