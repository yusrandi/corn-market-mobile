import '../../models/product_model.dart';
import '../../models/banner_model.dart';
import '../../models/category_model.dart';
import '../../models/review_model.dart';
import '../../models/order_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/user_model.dart';

abstract class IProductRepository {
  Future<List<ProductModel>>  getProducts({String? categorySlug, String? query});
  Future<List<ProductModel>>  getPopularProducts();
  Future<List<ProductModel>>  getNewProducts();
  Future<ProductModel?>       getProductById(String id);
  Future<List<CategoryModel>> getCategories();
  Future<List<BannerModel>>   getBanners();
  Stream<List<ProductModel>>  watchProducts({String? categorySlug});
  Future<String>              uploadProductImage(String filePath);
}

abstract class IReviewRepository {
  Future<List<ReviewModel>> getReviews(String productId);
  Future<void>              addReview(ReviewModel review);
}

abstract class IOrderRepository {
  Future<List<OrderModel>> getOrders(String userId);
  Future<OrderModel> createOrder({
    required String userId,
    required List<CartItemModel> items,
    required double subtotal,
    required double shippingFee,
    required double total,
    required String address,
    required String paymentMethod,
    String bankName,
    String bankAccount,
    String bankHolder,
  });
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> uploadPaymentProof(String orderId, String filePath); // ← NEW
  Stream<OrderModel> watchOrder(String orderId);
}

abstract class IAuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register(String name, String email, String phone, String password);
  Future<void>       logout();
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> updateProfile({String? name, String? phone, String? address, String? avatarPath});
  Stream<UserModel?> watchAuthState();
}

abstract class IStorageRepository {
  Future<String> uploadAvatar(String userId, String filePath);
  Future<String> uploadProductImage(String productId, String filePath);
  Future<String> uploadPaymentProof(String orderId, String userId, String filePath); // ← NEW
  Future<void>   deleteFile(String bucket, String path);
}
