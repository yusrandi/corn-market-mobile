import 'cart_item_model.dart';

enum OrderStatus { pending, confirmed, processing, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final String orderNumber;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String? trackingNumber;
  final String address;
  final String paymentMethod;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.trackingNumber,
    required this.address,
    required this.paymentMethod,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:     return 'Menunggu Konfirmasi';
      case OrderStatus.confirmed:   return 'Dikonfirmasi';
      case OrderStatus.processing:  return 'Diproses';
      case OrderStatus.shipped:     return 'Dikirim';
      case OrderStatus.delivered:   return 'Selesai';
      case OrderStatus.cancelled:   return 'Dibatalkan';
    }
  }

  String get statusEmoji {
    switch (status) {
      case OrderStatus.pending:     return '⏳';
      case OrderStatus.confirmed:   return '✅';
      case OrderStatus.processing:  return '📦';
      case OrderStatus.shipped:     return '🚚';
      case OrderStatus.delivered:   return '🎉';
      case OrderStatus.cancelled:   return '❌';
    }
  }
}
