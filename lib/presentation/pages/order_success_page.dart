import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../widgets/common/primary_button.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final txtSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated success icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPale,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('🎉', style: TextStyle(fontSize: 58))),
                ),
              ),
              const SizedBox(height: 32),
              Text('Pesanan Berhasil!', style: AppTextStyles.displayMedium.copyWith(color: txtPri)),
              const SizedBox(height: 12),
              Text(
                'Terima kasih sudah belanja di CornMarket.\nPesananmu sedang kami proses.',
                style: AppTextStyles.bodyLarge.copyWith(color: txtSec),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Order info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  border: Border.all(color: AppColors.primaryLight, width: 1.5),
                ),
                child: Column(children: [
                  _InfoRow('No. Pesanan', 'CM-2024-${DateTime.now().millisecond}', isDark),
                  const SizedBox(height: 8),
                  _InfoRow('Status', '⏳ Menunggu Konfirmasi', isDark),
                  const SizedBox(height: 8),
                  _InfoRow('Estimasi Tiba', '2-3 Hari Kerja', isDark),
                ]),
              ),
              const Spacer(),

              PrimaryButton(
                label: 'Lacak Pesanan',
                onPressed: () => Get.offAllNamed(AppRoutes.orders),
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.main),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: Text('Kembali Belanja',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryDark)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _InfoRow(this.label, this.value, this.isDark);
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
    const Spacer(),
    Text(value, style: AppTextStyles.titleMedium.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
  ]);
}
