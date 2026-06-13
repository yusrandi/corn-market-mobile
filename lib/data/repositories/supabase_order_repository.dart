import 'dart:io';
import 'package:corn_market/data/models/cart_item_model.dart';
import 'package:corn_market/data/models/order_model.dart';
import 'package:corn_market/data/models/product_model.dart';
import 'package:corn_market/data/repositories/interfaces/repository_interfaces.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOrderRepository implements IOrderRepository {
  final _db = Supabase.instance.client;

  static const _paymentProofBucket = 'payment-proofs';

  // ── Get orders ────────────────────────────────────────────

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    final data = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List<dynamic>)
        .map((e) => _orderFromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ── Create order ──────────────────────────────────────────

  @override
  Future<OrderModel> createOrder({
    required String userId,
    required List<CartItemModel> items,
    required double subtotal,
    required double shippingFee,
    required double total,
    required String address,
    required String paymentMethod,
    String bankName = '',
    String bankAccount = '',
    String bankHolder = '',
  }) async {
    final orderData = await _db
        .from('orders')
        .insert({
          'user_id': userId,
          'status': 'pending',
          'payment_status': 'unpaid',
          'subtotal': subtotal,
          'shipping_fee': shippingFee,
          'total': total,
          'address': address,
          'payment_method': paymentMethod,
          'bank_name': bankName,
          'bank_account': bankAccount,
          'bank_holder': bankHolder,
        })
        .select()
        .single();

    final orderId = orderData['id'] as String;

    await _db.from('order_items').insert(items
        .map((item) => {
              'order_id': orderId,
              'product_id': item.product.id,
              'name': item.product.name,
              'image_url': item.product.imageUrl,
              'price': item.product.price,
              'quantity': item.quantity,
              'subtotal': item.subtotal,
              'unit': item.product.unit,
            })
        .toList());

    final full = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();
    return _orderFromMap(full);
  }

  // ── Upload payment proof ───────────────────────────────────

  @override
  Future<void> uploadPaymentProof(String orderId, String filePath) async {
    final userId = _db.auth.currentUser?.id ?? 'unknown';
    final file = File(filePath);
    final ext = filePath.split('.').last;
    final path = '$userId/$orderId.$ext';

    await _db.storage
        .from(_paymentProofBucket)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = _db.storage.from(_paymentProofBucket).getPublicUrl(path);

    await _db.from('orders').update({
      'payment_proof_url': publicUrl,
      'payment_status': 'pending_verification',
    }).eq('id', orderId);
  }

  // ── Update status ─────────────────────────────────────────

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.from('orders').update({'status': status.name}).eq('id', orderId);
  }

  // ── Realtime ──────────────────────────────────────────────

  @override
  Stream<OrderModel> watchOrder(String orderId) {
    return _db
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((rows) {
          if (rows.isEmpty) throw Exception('Order not found');
          return _orderFromMap(rows.first);
        });
  }

  // ── Mapper ────────────────────────────────────────────────

  OrderModel _orderFromMap(Map<String, dynamic> m) {
    final rawItems = m['order_items'] as List? ?? [];
    final items = rawItems
        .map((i) => CartItemModel(
              product: ProductModel(
                id: i['product_id'] as String,
                name: i['name'] as String,
                description: '',
                price: (i['price'] as num).toDouble(),
                pricePerUnit: (i['price'] as num).toDouble(),
                unit: i['unit'] as String? ?? 'kg',
                imageUrl: i['image_url'] as String? ?? '',
                category: '',
                rating: 0,
                reviewCount: 0,
                stock: 0,
                origin: '',
              ),
              quantity: i['quantity'] as int,
            ))
        .toList();

    return OrderModel(
      id: m['id'] as String,
      orderNumber: m['order_number'] as String? ?? '-',
      items: items,
      subtotal: (m['subtotal'] as num).toDouble(),
      shippingFee: (m['shipping_fee'] as num).toDouble(),
      total: (m['total'] as num).toDouble(),
      status: _statusFromStr(m['status'] as String? ?? 'pending'),
      paymentStatus:
          _paymentStatusFromStr(m['payment_status'] as String? ?? 'unpaid'),
      createdAt: DateTime.parse(m['created_at'] as String),
      trackingNumber: m['tracking_number'] as String?,
      address: m['address'] as String? ?? '',
      paymentMethod: m['payment_method'] as String? ?? '',
      bankName: m['bank_name'] as String? ?? '',
      bankAccount: m['bank_account'] as String? ?? '',
      bankHolder: m['bank_holder'] as String? ?? '',
      paymentProofUrl: m['payment_proof_url'] as String?,
    );
  }

  OrderStatus _statusFromStr(String s) {
    switch (s) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  PaymentStatus _paymentStatusFromStr(String s) {
    switch (s) {
      case 'pending_verification':
        return PaymentStatus.pendingVerification;
      case 'verified':
        return PaymentStatus.verified;
      case 'rejected':
        return PaymentStatus.rejected;
      default:
        return PaymentStatus.unpaid;
    }
  }
}
