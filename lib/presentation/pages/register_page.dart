import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../widgets/common/corn_app_bar.dart';
import '../widgets/common/primary_button.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: const CornAppBar(title: 'Buat Akun Baru'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text('🌽', style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text('Bergabung dengan\npetani & pembeli lokal', style: AppTextStyles.headlineMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _buildLabel('Nama Lengkap'),
              _buildField(_nameCtrl, 'Ahmad Fauzi', Icons.person_outline_rounded),
              _buildLabel('Email'),
              _buildField(_emailCtrl, 'contoh@email.com', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              _buildLabel('No. Telepon / WhatsApp'),
              _buildField(_phoneCtrl, '0812-xxxx-xxxx', Icons.phone_outlined, keyboardType: TextInputType.phone),

              _buildLabel('Password'),
              Obx(() => _buildField(
                _passwordCtrl, 'Minimal 6 karakter', Icons.lock_outline_rounded,
                obscure: auth.obscurePassword.value,
                suffix: IconButton(
                  icon: Icon(auth.obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: auth.toggleObscurePassword,
                ),
              )),
              _buildLabel('Konfirmasi Password'),
              Obx(() => _buildField(
                _confirmCtrl, 'Ulangi password', Icons.lock_outline_rounded,
                obscure: auth.obscureConfirmPassword.value,
                suffix: IconButton(
                  icon: Icon(auth.obscureConfirmPassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: auth.toggleObscureConfirm,
                ),
              )),

              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'Dengan mendaftar, kamu setuju dengan ',
                  style: AppTextStyles.bodyMedium,
                  children: [
                    TextSpan(
                      text: 'Syarat & Ketentuan',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondary, fontSize: 13),
                    ),
                    const TextSpan(text: ' kami.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Obx(() => PrimaryButton(
                label: 'Daftar Sekarang',
                isLoading: auth.isLoading.value,
                onPressed: () => auth.register(
                  _nameCtrl.text, _emailCtrl.text, _phoneCtrl.text, _passwordCtrl.text,
                ),
              )),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun? ',
                      style: AppTextStyles.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 16),
    child: Text(text, style: AppTextStyles.titleMedium),
  );

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: suffix,
        ),
      );
}
