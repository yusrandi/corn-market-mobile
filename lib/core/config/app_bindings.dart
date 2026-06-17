import 'package:corn_market/data/repositories/interfaces/repository_interfaces.dart';
import 'package:corn_market/data/repositories/supabase_auth_repository.dart';
import 'package:corn_market/data/repositories/supabase_order_repository.dart';
import 'package:corn_market/data/repositories/supabase_product_repository.dart';
import 'package:corn_market/data/repositories/supabase_review_repository.dart';
import 'package:corn_market/presentation/controllers/auth_controller.dart';
import 'package:corn_market/presentation/controllers/cart_controller.dart';
import 'package:corn_market/presentation/controllers/chat_controller.dart';
import 'package:corn_market/presentation/controllers/favorites_controller.dart';
import 'package:corn_market/presentation/controllers/home_controller.dart';
import 'package:corn_market/presentation/controllers/main_controller.dart';
import 'package:corn_market/presentation/controllers/theme_controller.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ── Repositories (lazy singleton) ─────────────────────
    Get.lazyPut<IProductRepository>(
      () => SupabaseProductRepository(),
      fenix: true,
    );
    Get.lazyPut<IAuthRepository>(
      () => SupabaseAuthRepository(),
      fenix: true,
    );
    Get.lazyPut<IOrderRepository>(
      () => SupabaseOrderRepository(),
      fenix: true,
    );
    Get.lazyPut<IReviewRepository>(
      () => SupabaseReviewRepository(),
      fenix: true,
    );

    // ── Controllers (permanent) ───────────────────────────
    Get.put(ThemeController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
    Get.put(MainController(), permanent: true);

    // Auth & Home depend on repositories
    Get.put(
      AuthController(authRepo: Get.find<IAuthRepository>()),
      permanent: true,
    );
    Get.put(ChatController(), permanent: true);
    Get.put(
      HomeController(
        productRepo: Get.find<IProductRepository>(),
      ),
      permanent: true,
    );
  }
}
