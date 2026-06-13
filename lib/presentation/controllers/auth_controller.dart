import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/interfaces/repository_interfaces.dart';

class AuthController extends GetxController {
  final IAuthRepository authRepo;
  AuthController({required this.authRepo});

  final RxBool   isLoggedIn  = false.obs;
  final RxBool   isLoading   = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Form errors
  final RxString emailError    = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString generalError  = ''.obs;

  // Password visibility
  final RxBool obscurePassword        = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkSession();
    _listenAuthState();
  }

  // ── Session check on startup ──────────────────────────────

  Future<void> _checkSession() async {
    isLoading.value = true;
    try {
      final user = await authRepo.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
        isLoggedIn.value  = true;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (_) {}
    isLoading.value = false;
  }

  // ── Realtime auth state ───────────────────────────────────

  void _listenAuthState() {
    authRepo.watchAuthState().listen((user) {
      currentUser.value = user;
      isLoggedIn.value  = user != null;
    });
  }

  // ── Login ─────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    _clearErrors();

    if (email.trim().isEmpty) { emailError.value = 'Email tidak boleh kosong'; return; }
    if (!GetUtils.isEmail(email.trim())) { emailError.value = 'Format email tidak valid'; return; }
    if (password.isEmpty) { passwordError.value = 'Password tidak boleh kosong'; return; }
    if (password.length < 6) { passwordError.value = 'Password minimal 6 karakter'; return; }

    isLoading.value = true;
    try {
      final user = await authRepo.login(email, password);
      if (user != null) {
        currentUser.value = user;
        isLoggedIn.value  = true;
        Get.offAllNamed(AppRoutes.main);
      } else {
        generalError.value = 'Login gagal. Periksa email & password kamu.';
      }
    } on Exception catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('invalid') || msg.contains('credentials')) {
        generalError.value = 'Email atau password salah.';
      } else if (msg.contains('email not confirmed')) {
        generalError.value = 'Email belum dikonfirmasi. Cek inbox kamu.';
      } else {
        generalError.value = 'Terjadi kesalahan. Coba lagi.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Register ──────────────────────────────────────────────

  Future<void> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    _clearErrors();

    if (name.trim().isEmpty) { generalError.value = 'Nama tidak boleh kosong'; return; }
    if (!GetUtils.isEmail(email.trim())) { emailError.value = 'Format email tidak valid'; return; }
    if (password.length < 6) { passwordError.value = 'Password minimal 6 karakter'; return; }

    isLoading.value = true;
    try {
      final user = await authRepo.register(name, email, phone, password);
      if (user != null) {
        currentUser.value = user;
        isLoggedIn.value  = true;
        Get.offAllNamed(AppRoutes.main);
      }
    } on Exception catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('already registered') || msg.contains('already exists')) {
        emailError.value = 'Email sudah terdaftar.';
      } else {
        generalError.value = 'Registrasi gagal. Coba lagi.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Update profile ────────────────────────────────────────

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? avatarPath,
  }) async {
    isLoading.value = true;
    try {
      final updated = await authRepo.updateProfile(
        name: name, phone: phone, address: address, avatarPath: avatarPath,
      );
      if (updated != null) {
        currentUser.value = updated;
        Get.snackbar('Berhasil ✅', 'Profil berhasil diperbarui',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12);
      }
    } catch (_) {
      Get.snackbar('Gagal', 'Gagal memperbarui profil',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────

  Future<void> logout() async {
    await authRepo.logout();
    currentUser.value = null;
    isLoggedIn.value  = false;
    Get.offAllNamed(AppRoutes.login);
  }

  // ── Helpers ───────────────────────────────────────────────

  void _clearErrors() {
    emailError.value    = '';
    passwordError.value = '';
    generalError.value  = '';
  }

  void toggleObscurePassword() => obscurePassword.value = !obscurePassword.value;
  void toggleObscureConfirm()  => obscureConfirmPassword.value = !obscureConfirmPassword.value;
}
