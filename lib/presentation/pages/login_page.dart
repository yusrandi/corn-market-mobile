import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/animations/animation_widgets.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth   = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              ScaleInWidget(
                delay: const Duration(milliseconds: 100),
                beginScale: 0.6,
                child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: Text('🌽', style: TextStyle(fontSize: 40))),
                    ),
                    const SizedBox(height: 16),
                    Text('CornMarket', style: AppTextStyles.displayMedium),
                    const SizedBox(height: 4),
                    Text('Masuk ke akunmu', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 40),

              // Email
              Text('Email', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'contoh@email.com',
                  hintStyle: AppTextStyles.bodyMedium,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  errorText: auth.emailError.value.isEmpty ? null : auth.emailError.value,
                ),
              )),
              const SizedBox(height: 16),

              // Password
              Text('Password', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: _passwordCtrl,
                obscureText: auth.obscurePassword.value,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Masukkan password',
                  hintStyle: AppTextStyles.bodyMedium,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      auth.obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: auth.toggleObscurePassword,
                  ),
                  errorText: auth.passwordError.value.isEmpty ? null : auth.passwordError.value,
                ),
              )),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('Lupa password?', style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondary)),
                ),
              ),
              const SizedBox(height: 8),

              // Login Button
              Obx(() => PrimaryButton(
                label: 'Masuk',
                isLoading: auth.isLoading.value,
                onPressed: () => auth.login(_emailCtrl.text, _passwordCtrl.text),
              )),
              const SizedBox(height: 20),

              // Divider
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('atau', style: AppTextStyles.bodyMedium),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 20),

              // Demo login
              OutlinedButton(
                onPressed: () => auth.login('ahmad@example.com', 'password123'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: Text('🌽  Login Demo', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryDark)),
              ),
              const SizedBox(height: 32),

              // Register link
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.register),
                  child: RichText(
                    text: TextSpan(
                      text: 'Belum punya akun? ',
                      style: AppTextStyles.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Daftar Sekarang',
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
