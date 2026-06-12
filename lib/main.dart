import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/cart_controller.dart';
import 'presentation/controllers/favorites_controller.dart';
import 'presentation/controllers/home_controller.dart';
import 'presentation/controllers/main_controller.dart';
import 'presentation/controllers/theme_controller.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/main_shell.dart';
import 'presentation/pages/product_detail_page.dart';
import 'presentation/pages/checkout_page.dart';
import 'presentation/pages/order_success_page.dart';
import 'presentation/pages/orders_page.dart';
import 'presentation/pages/order_detail_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CornMarketApp());
}

class CornMarketApp extends StatelessWidget {
  const CornMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
    Get.put(MainController(), permanent: true);
    Get.put(HomeController(), permanent: true);

    final themeCtrl = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'CornMarket',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeCtrl.themeMode,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),
          initialRoute: AppRoutes.splash,
          getPages: [
            GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
            GetPage(
              name: AppRoutes.onboarding,
              page: () => const OnboardingPage(),
              transition: Transition.fade,
            ),
            GetPage(
              name: AppRoutes.login,
              page: () => LoginPage(),
              transition: Transition.fadeIn,
            ),
            GetPage(name: AppRoutes.register, page: () => RegisterPage()),
            GetPage(
              name: AppRoutes.main,
              page: () => const MainShell(),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: AppRoutes.detail,
              page: () => const ProductDetailPage(),
              transition: Transition.downToUp,
            ),
            GetPage(name: AppRoutes.checkout, page: () => const CheckoutPage()),
            GetPage(
              name: AppRoutes.orderSuccess,
              page: () => const OrderSuccessPage(),
              transition: Transition.zoom,
            ),
            GetPage(name: AppRoutes.orders, page: () => const OrdersPage()),
            GetPage(
                name: AppRoutes.orderDetail,
                page: () => const OrderDetailPage()),
          ],
        ));
  }
}
