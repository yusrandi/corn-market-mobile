import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/interfaces/repository_interfaces.dart';
import '../widgets/common/corn_app_bar.dart';
import '../widgets/animations/animation_widgets.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});
  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _uploading = false;

  Future<void> _pickAndUploadProof(OrderModel order) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final orderRepo = Get.find<IOrderRepository>();
      await orderRepo.uploadPaymentProof(order.id, picked.path);
      if (mounted) {
        Get.snackbar(
          'Berhasil! ✅',
          'Bukti transfer berhasil diunggah.\nAdmin akan memverifikasi dalam 1×24 jam.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        // Reload page
        Get.back();
        Get.toNamed('/order-detail', arguments: order);
      }
    } catch (e) {
      Get.snackbar('Gagal 😢', 'Gagal upload bukti. Coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as OrderModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf = isDark ? AppColors.darkSurface : AppColors.surface;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final txtSec =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: CornAppBar(
        title: order.orderNumber,
        actions: [
          IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Payment Status Banner ─────────────────────────
          SlideInWidget(
            child: _PaymentStatusBanner(order: order, isDark: isDark),
          ),
          const SizedBox(height: 14),

          // ── Upload Bukti Transfer ─────────────────────────
          if (order.paymentStatus == PaymentStatus.unpaid ||
              order.paymentStatus == PaymentStatus.rejected)
            SlideInWidget(
              delay: const Duration(milliseconds: 80),
              child: _UploadProofCard(
                order: order,
                isDark: isDark,
                uploading: _uploading,
                onUpload: () => _pickAndUploadProof(order),
              ),
            ),

          // ── Bukti sudah diupload ──────────────────────────
          if (order.paymentProofUrl != null &&
              order.paymentProofUrl!.isNotEmpty)
            SlideInWidget(
              delay: const Duration(milliseconds: 80),
              child: _ProofPreviewCard(
                  order: order,
                  isDark: isDark,
                  surf: surf,
                  txtPri: txtPri,
                  txtSec: txtSec),
            ),

          const SizedBox(height: 14),

          // ── Tracking Timeline ─────────────────────────────
          SlideInWidget(
            delay: const Duration(milliseconds: 120),
            child: _Card(
                isDark: isDark,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🚚 Status Pengiriman',
                          style:
                              AppTextStyles.titleLarge.copyWith(color: txtPri)),
                      const SizedBox(height: 4),
                      if (order.trackingNumber != null &&
                          order.trackingNumber!.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: order.trackingNumber!));
                            Get.snackbar('Disalin 📋', 'No. resi disalin',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                                margin: const EdgeInsets.all(16));
                          },
                          child: Row(children: [
                            Text('No. Resi: ${order.trackingNumber}',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.secondary)),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_rounded,
                                size: 14, color: AppColors.secondary),
                          ]),
                        ),
                      const SizedBox(height: 20),
                      _TrackingTimeline(status: order.status, isDark: isDark),
                    ])),
          ),
          const SizedBox(height: 14),

          // ── Info Alamat ───────────────────────────────────
          SlideInWidget(
            delay: const Duration(milliseconds: 160),
            child: _Card(
                isDark: isDark,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📍 Alamat Pengiriman',
                          style:
                              AppTextStyles.titleLarge.copyWith(color: txtPri)),
                      const SizedBox(height: 8),
                      Text(order.address,
                          style:
                              AppTextStyles.bodyLarge.copyWith(color: txtSec)),
                    ])),
          ),
          const SizedBox(height: 14),

          // ── Rekening tujuan ───────────────────────────────
          if (order.bankName.isNotEmpty)
            SlideInWidget(
              delay: const Duration(milliseconds: 180),
              child: _Card(
                  isDark: isDark,
                  color: AppColors.primaryLight,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🏦 Rekening Tujuan Transfer',
                            style: AppTextStyles.titleLarge
                                .copyWith(color: AppColors.primaryDark)),
                        const SizedBox(height: 10),
                        _BankRow('Bank', order.bankName),
                        _BankRow('Nomor Rekening', order.bankAccount,
                            copyable: true),
                        _BankRow('Atas Nama', order.bankHolder),
                        _BankRow('Nominal Transfer',
                            CurrencyFormatter.format(order.total),
                            bold: true),
                      ])),
            ),
          const SizedBox(height: 14),

          // ── Detail Produk ─────────────────────────────────
          SlideInWidget(
            delay: const Duration(milliseconds: 200),
            child: _Card(
                isDark: isDark,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🌽 Detail Produk',
                          style:
                              AppTextStyles.titleLarge.copyWith(color: txtPri)),
                      const SizedBox(height: 12),
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                      width: 56,
                                      height: 56,
                                      color: AppColors.primaryLight,
                                      child: const Center(child: Text('🌽'))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(item.product.name,
                                        style: AppTextStyles.titleMedium
                                            .copyWith(color: txtPri),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        '${CurrencyFormatter.format(item.product.price)} × ${item.quantity} ${item.product.unit}',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(color: txtSec)),
                                  ])),
                              Text(CurrencyFormatter.format(item.subtotal),
                                  style: AppTextStyles.priceStyle),
                            ]),
                          )),
                    ])),
          ),
          const SizedBox(height: 14),

          // ── Ringkasan Pembayaran ──────────────────────────
          SlideInWidget(
            delay: const Duration(milliseconds: 220),
            child: _Card(
                isDark: isDark,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('💳 Ringkasan Pembayaran',
                          style:
                              AppTextStyles.titleLarge.copyWith(color: txtPri)),
                      const SizedBox(height: 12),
                      _SummaryRow(
                          'Subtotal',
                          CurrencyFormatter.format(order.subtotal),
                          txtPri,
                          txtSec),
                      const SizedBox(height: 6),
                      _SummaryRow(
                          'Ongkir',
                          order.shippingFee == 0
                              ? 'GRATIS'
                              : CurrencyFormatter.format(order.shippingFee),
                          order.shippingFee == 0 ? AppColors.success : txtPri,
                          txtSec),
                      Divider(
                          height: 20,
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.divider),
                      _SummaryRow(
                          'Total',
                          CurrencyFormatter.format(order.total),
                          AppColors.secondary,
                          txtSec,
                          bold: true),
                    ])),
          ),
          const SizedBox(height: 32),

          // ── CTA ───────────────────────────────────────────
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

// ── Payment Status Banner ─────────────────────────────────────

class _PaymentStatusBanner extends StatelessWidget {
  final OrderModel order;
  final bool isDark;
  const _PaymentStatusBanner({required this.order, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (order.paymentStatus) {
      case PaymentStatus.unpaid:
        bg = AppColors.warning.withOpacity(0.12);
        fg = AppColors.warning;
        break;
      case PaymentStatus.pendingVerification:
        bg = AppColors.info.withOpacity(0.12);
        fg = AppColors.info;
        break;
      case PaymentStatus.verified:
        bg = AppColors.success.withOpacity(0.12);
        fg = AppColors.success;
        break;
      case PaymentStatus.rejected:
        bg = AppColors.error.withOpacity(0.12);
        fg = AppColors.error;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
      child: Row(children: [
        Text(order.paymentStatusEmoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Status Pembayaran',
              style: AppTextStyles.labelLarge
                  .copyWith(color: fg.withOpacity(0.7))),
          Text(order.paymentStatusLabel,
              style: AppTextStyles.titleMedium
                  .copyWith(color: fg, fontWeight: FontWeight.w700)),
          if (order.paymentStatus == PaymentStatus.unpaid)
            Text('Upload bukti transfer di bawah setelah melakukan pembayaran',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: fg.withOpacity(0.8))),
          if (order.paymentStatus == PaymentStatus.pendingVerification)
            Text('Admin akan memverifikasi dalam 1×24 jam',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: fg.withOpacity(0.8))),
        ])),
      ]),
    );
  }
}

// ── Upload Proof Card ─────────────────────────────────────────

class _UploadProofCard extends StatelessWidget {
  final OrderModel order;
  final bool isDark;
  final bool uploading;
  final VoidCallback onUpload;
  const _UploadProofCard(
      {required this.order,
      required this.isDark,
      required this.uploading,
      required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final surf = isDark ? AppColors.darkSurface : AppColors.surface;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📸 Upload Bukti Transfer',
            style: AppTextStyles.titleLarge.copyWith(color: txtPri)),
        const SizedBox(height: 4),
        Text(
          order.paymentStatus == PaymentStatus.rejected
              ? 'Bukti sebelumnya ditolak. Upload ulang bukti yang benar.'
              : 'Upload struk/screenshot transfer bank kamu',
          style: AppTextStyles.bodyMedium.copyWith(
            color: order.paymentStatus == PaymentStatus.rejected
                ? AppColors.error
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: uploading ? null : onUpload,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            child: uploading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2))
                : Column(children: [
                    const Icon(Icons.upload_rounded,
                        size: 32, color: AppColors.primaryDark),
                    const SizedBox(height: 8),
                    Text('Pilih dari Galeri',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.primaryDark)),
                    Text('JPG, PNG, atau PDF',
                        style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primaryDark.withOpacity(0.6))),
                  ]),
          ),
        ),
      ]),
    );
  }
}

// ── Proof Preview ─────────────────────────────────────────────

class _ProofPreviewCard extends StatelessWidget {
  final OrderModel order;
  final bool isDark;
  final Color surf, txtPri, txtSec;
  const _ProofPreviewCard(
      {required this.order,
      required this.isDark,
      required this.surf,
      required this.txtPri,
      required this.txtSec});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          boxShadow: [
            BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🧾 Bukti Transfer',
              style: AppTextStyles.titleLarge.copyWith(color: txtPri)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            child: Image.network(
              order.paymentProofUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                color: AppColors.primaryLight,
                child: const Center(
                    child: Text('📄', style: TextStyle(fontSize: 40))),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Diunggah · menunggu verifikasi admin',
              style: AppTextStyles.labelLarge.copyWith(color: txtSec)),
        ]),
      );
}

// ── Tracking Timeline ─────────────────────────────────────────

class _TrackingTimeline extends StatelessWidget {
  final OrderStatus status;
  final bool isDark;
  const _TrackingTimeline({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (OrderStatus.pending, '⏳', 'Menunggu', 'Pesanan kamu sudah masuk'),
      (OrderStatus.confirmed, '✅', 'Dikonfirmasi', 'Penjual mengonfirmasi'),
      (OrderStatus.processing, '📦', 'Diproses', 'Jagung sedang disiapkan'),
      (OrderStatus.shipped, '🚚', 'Dikirim', 'Dalam perjalanan'),
      (OrderStatus.delivered, '🎉', 'Selesai', 'Pesanan diterima'),
    ];
    final currentIdx = steps.indexWhere((s) => s.$1 == status);

    return Column(
        children: List.generate(steps.length, (i) {
      final step = steps[i];
      final isDone = i <= currentIdx;
      final isCurrent = i == currentIdx;
      final isLast = i == steps.length - 1;

      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.secondary
                    : (isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.surfaceVariant),
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Center(
                  child: Text(step.$2, style: const TextStyle(fontSize: 16))),
            ),
            if (!isLast)
              Expanded(
                  child: Container(
                width: 2,
                color: isDone
                    ? AppColors.secondaryLight
                    : (isDark ? AppColors.darkDivider : AppColors.divider),
              )),
          ]),
          const SizedBox(width: 14),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 6),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(step.$3,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDone
                        ? (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary)
                        : (isDark
                            ? AppColors.darkTextHint
                            : AppColors.textHint),
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  )),
              Text(step.$4,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDone
                        ? (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary)
                        : (isDark
                            ? AppColors.darkTextHint
                            : AppColors.textHint),
                  )),
            ]),
          )),
        ]),
      );
    }));
  }
}

// ── Helpers ───────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color? color;
  const _Card({required this.child, required this.isDark, this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? (isDark ? AppColors.darkSurface : AppColors.surface),
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          boxShadow: const [
            BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: Offset(2, 2))
          ],
        ),
        child: child,
      );
}

class _BankRow extends StatelessWidget {
  final String label, value;
  final bool copyable, bold;
  const _BankRow(this.label, this.value,
      {this.copyable = false, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(
              width: 130,
              child: Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryDark.withOpacity(0.7)))),
          Expanded(
              child: Text(': $value',
                  style: bold
                      ? AppTextStyles.titleLarge
                          .copyWith(color: AppColors.primaryDark)
                      : AppTextStyles.titleMedium
                          .copyWith(color: AppColors.primaryDark))),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.snackbar('Disalin 📋', 'Nomor rekening disalin',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(16));
              },
              child: const Icon(Icons.copy_rounded,
                  size: 16, color: AppColors.primaryDark),
            ),
        ]),
      );
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color valueColor, labelColor;
  final bool bold;
  const _SummaryRow(this.label, this.value, this.valueColor, this.labelColor,
      {this.bold = false});
  @override
  Widget build(BuildContext context) => Row(children: [
        Text(label,
            style: AppTextStyles.bodyMedium.copyWith(color: labelColor)),
        const Spacer(),
        Text(value,
            style: bold
                ? AppTextStyles.headlineMedium.copyWith(color: valueColor)
                : AppTextStyles.titleMedium.copyWith(color: valueColor)),
      ]);
}
