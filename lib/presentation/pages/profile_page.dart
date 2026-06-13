import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/currency_formatter.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/common/corn_app_bar.dart';
import '../widgets/animations/animation_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = Get.find<AuthController>();
    final theme  = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf   = isDark ? AppColors.darkSurface : AppColors.surface;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final txtSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final bg     = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      appBar: CornAppBar(
        title: 'Profil Saya',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _pickAndUploadAvatar(context, auth),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [

          // Header card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppConstants.horizontalPadding),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.secondaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Obx(() {
              final user = auth.currentUser.value;
              return Row(children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                  backgroundColor: AppColors.primaryLight,
                  child: user?.avatarUrl == null
                      ? Text(user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.secondary))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.name ?? 'Pengguna', style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
                  Text(user?.email ?? '', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                  Text(user?.phone ?? '', style: AppTextStyles.labelLarge.copyWith(color: Colors.white60)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(100)),
                  child: Text('Member', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ]);
            }),
          ),

          // Stats row
          Obx(() {
            final user = auth.currentUser.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
              child: Row(children: [
                _StatCard(
                  label: 'Total Pesanan',
                  value: '${user?.totalOrders ?? 0}',
                  icon: '📦',
                  isDark: isDark,
                  surf: surf,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Total Belanja',
                  value: CurrencyFormatter.formatCompact(user?.totalSpent ?? 0),
                  icon: '💰',
                  isDark: isDark,
                  surf: surf,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Favorit',
                  value: '8',
                  icon: '❤️',
                  isDark: isDark,
                  surf: surf,
                ),
              ]),
            );
          }),
          const SizedBox(height: 20),

          // Menu sections
          _MenuSection(
            title: 'Akun & Pesanan',
            items: [
              _MenuItem(icon: Icons.shopping_bag_outlined, label: 'Riwayat Pesanan', onTap: () => Get.toNamed(AppRoutes.orders)),
              _MenuItem(icon: Icons.favorite_outline_rounded, label: 'Produk Favorit', onTap: () {}),
              _MenuItem(icon: Icons.location_on_outlined, label: 'Alamat Tersimpan', onTap: () {}),
              _MenuItem(icon: Icons.payment_outlined, label: 'Metode Pembayaran', onTap: () {}),
            ],
            isDark: isDark, surf: surf, txtPri: txtPri, txtSec: txtSec,
          ),
          const SizedBox(height: 12),

          _MenuSection(
            title: 'Pengaturan',
            items: [
              _MenuItem(
                icon: Icons.dark_mode_outlined,
                label: 'Mode Gelap',
                onTap: () {},
                trailing: Obx(() => Switch(
                  value: theme.isDarkMode.value,
                  onChanged: (_) => theme.toggleTheme(),
                  activeColor: AppColors.primary,
                )),
              ),
              _MenuItem(icon: Icons.notifications_none_rounded, label: 'Notifikasi', onTap: () {}),
              _MenuItem(icon: Icons.language_outlined, label: 'Bahasa', trailing: Text('Indonesia', style: AppTextStyles.bodyMedium.copyWith(color: txtSec)), onTap: () {}),
            ],
            isDark: isDark, surf: surf, txtPri: txtPri, txtSec: txtSec,
          ),
          const SizedBox(height: 12),

          _MenuSection(
            title: 'Lainnya',
            items: [
              _MenuItem(icon: Icons.help_outline_rounded, label: 'Bantuan & FAQ', onTap: () {}),
              _MenuItem(icon: Icons.shield_outlined, label: 'Kebijakan Privasi', onTap: () {}),
              _MenuItem(icon: Icons.info_outline_rounded, label: 'Tentang Aplikasi', onTap: () {}),
            ],
            isDark: isDark, surf: surf, txtPri: txtPri, txtSec: txtSec,
          ),
          const SizedBox(height: 12),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
            child: GestureDetector(
              onTap: () => _confirmLogout(auth),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Text('Keluar', style: AppTextStyles.titleMedium.copyWith(color: AppColors.error)),
                ]),
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text('CornMarket v1.0.0', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Text('🌽 Jagung Segar dari Petani Lokal', style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary)),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }


  Future<void> _pickAndUploadAvatar(BuildContext context, AuthController auth) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    await auth.updateProfile(avatarPath: picked.path);
  }

  void _confirmLogout(AuthController auth) {
    Get.dialog(AlertDialog(
      title: const Text('Keluar?'),
      content: const Text('Kamu yakin ingin keluar dari akun?'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Batal')),
        TextButton(
          onPressed: auth.logout,
          child: const Text('Keluar', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ));
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  final bool isDark;
  final Color surf;
  const _StatCard({required this.label, required this.value, required this.icon, required this.isDark, required this.surf});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleLarge.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: isDark ? AppColors.darkTextHint : AppColors.textHint), textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  final bool isDark;
  final Color surf, txtPri, txtSec;
  const _MenuSection({required this.title, required this.items, required this.isDark, required this.surf, required this.txtPri, required this.txtSec});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title, style: AppTextStyles.labelLarge.copyWith(color: isDark ? AppColors.darkTextHint : AppColors.textHint, letterSpacing: 1)),
      ),
      Container(
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(children: [
            ListTile(
              onTap: item.onTap,
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
                child: Icon(item.icon, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
              title: Text(item.label, style: AppTextStyles.titleMedium.copyWith(color: txtPri)),
              trailing: item.trailing ?? Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkTextHint : AppColors.textHint, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            ),
            if (!isLast) Divider(height: 1, indent: 68, color: isDark ? AppColors.darkDivider : AppColors.divider),
          ]);
        })),
      ),
    ]),
  );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.trailing});
}
