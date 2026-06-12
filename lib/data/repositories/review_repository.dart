import '../models/review_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'product_repository.dart';

class ReviewRepository {
  static List<ReviewModel> getReviews(String productId) {
    return [
      ReviewModel(
        id: 'r1',
        userName: 'Siti Rahayu',
        userAvatar: 'https://i.pravatar.cc/100?img=1',
        rating: 5.0,
        comment: 'Jagungnya manis banget! Segar, baru dipanen. Packing rapi dan pengiriman cepat. Recommended!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerified: true,
      ),
      ReviewModel(
        id: 'r2',
        userName: 'Budi Santoso',
        userAvatar: 'https://i.pravatar.cc/100?img=3',
        rating: 4.5,
        comment: 'Kualitas bagus, harga terjangkau. Cocok buat usaha gorengan saya. Akan order lagi!',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
      ),
      ReviewModel(
        id: 'r3',
        userName: 'Dewi Lestari',
        userAvatar: 'https://i.pravatar.cc/100?img=5',
        rating: 5.0,
        comment: 'Jagung manis terbaik yang pernah saya beli online. Langsung dari petani, rasanya beda!',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        isVerified: false,
      ),
      ReviewModel(
        id: 'r4',
        userName: 'Ahmad Fauzi',
        userAvatar: 'https://i.pravatar.cc/100?img=7',
        rating: 4.0,
        comment: 'Oke lah, sesuai deskripsi. Pengiriman agak lama tapi produk tetap segar waktu sampai.',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        isVerified: true,
      ),
    ];
  }
}

class OrderRepository {
  static List<OrderModel> getDummyOrders() {
    final products = ProductRepository.products;
    return [
      OrderModel(
        id: 'o1',
        orderNumber: 'CM-2024-001',
        items: [
          CartItemModel(product: products[0], quantity: 5),
          CartItemModel(product: products[1], quantity: 2),
        ],
        subtotal: 161000,
        shippingFee: 15000,
        total: 176000,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        trackingNumber: 'JNE123456789',
        address: 'Jl. Soekarno Hatta No. 12, Balikpapan Selatan',
        paymentMethod: 'Transfer Bank BCA',
      ),
      OrderModel(
        id: 'o2',
        orderNumber: 'CM-2024-002',
        items: [
          CartItemModel(product: products[3], quantity: 3),
        ],
        subtotal: 255000,
        shippingFee: 0,
        total: 255000,
        status: OrderStatus.shipped,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        trackingNumber: 'SICEPAT987654',
        address: 'Jl. MT Haryono No. 45, Samarinda Ulu',
        paymentMethod: 'QRIS / GoPay',
      ),
      OrderModel(
        id: 'o3',
        orderNumber: 'CM-2024-003',
        items: [
          CartItemModel(product: products[2], quantity: 10),
          CartItemModel(product: products[4], quantity: 2),
        ],
        subtotal: 210000,
        shippingFee: 12000,
        total: 222000,
        status: OrderStatus.processing,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        address: 'Jl. Pangeran Antasari No. 8, Balikpapan',
        paymentMethod: 'COD',
      ),
    ];
  }
}
