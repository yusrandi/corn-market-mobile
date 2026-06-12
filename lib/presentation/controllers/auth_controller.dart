import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';
import '../../data/models/user_model.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Form fields
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  static const _dummyUser = UserModel(
    id: 'u1',
    name: 'Ahmad Fauzi',
    email: 'ahmad@example.com',
    phone: '08123456789',
    avatarUrl: 'https://i.pravatar.cc/150?img=7',
    address: 'Jl. Soekarno Hatta No. 12, Balikpapan Selatan, Kalimantan Timur',
    totalOrders: 12,
    totalSpent: 1850000,
  );

  Future<void> login(String email, String password) async {
    emailError.value = '';
    passwordError.value = '';

    if (email.trim().isEmpty) {
      emailError.value = 'Email tidak boleh kosong';
      return;
    }
    if (!GetUtils.isEmail(email.trim())) {
      emailError.value = 'Format email tidak valid';
      return;
    }
    if (password.isEmpty) {
      passwordError.value = 'Password tidak boleh kosong';
      return;
    }
    if (password.length < 6) {
      passwordError.value = 'Password minimal 6 karakter';
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1500)); // simulate API
    isLoading.value = false;

    currentUser.value = _dummyUser;
    isLoggedIn.value = true;
    Get.offAllNamed(AppRoutes.main);
  }

  Future<void> register(
      String name, String email, String phone, String password) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1500));
    isLoading.value = false;

    currentUser.value = UserModel(
      id: 'u_new',
      name: name,
      email: email,
      phone: phone,
      address: '',
      totalOrders: 0,
      totalSpent: 0,
    );
    isLoggedIn.value = true;
    Get.offAllNamed(AppRoutes.main);
  }

  void logout() {
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  void toggleObscurePassword() =>
      obscurePassword.value = !obscurePassword.value;
  void toggleObscureConfirm() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;
}
