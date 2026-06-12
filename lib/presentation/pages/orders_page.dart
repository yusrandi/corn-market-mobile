import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/review_repository.dart';
import '../widgets/common/corn_app_bar.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/animations/animation_widgets.dart';
import '../widgets/shimmer/shimmer_misc.dart';
import '../widgets/shimmer/shimmer_box.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _isLoading = true;
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _orders    = OrderRepository.getDummyOrders();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf   = isDark ? AppColors.darkSurface : AppColors.surface;

    return Scaffold(
      appBar: const CornAppBar(title: 'Riwayat Pesanan', showBack: false),
      body: _isLoading
          ? ListView.separated(
              padding: const EdgeInsets.all(AppConstants.horizontalPadding),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
                ),
                child: const ShimmerOrderCard(),
              ),
            )
          : _orders.isEmpty
              ? const EmptyStateWidget(
                  emoji: '📦',
                  title: 'Belum Ada Pesanan',
                  subtitle: 'Yuk mulai belanja jagung segar!',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppConstants.horizontalPadding),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => SlideInWidget(
                    delay: Duration(milliseconds: 80 * i),
                    child: _OrderCard(order: _orders[i], isDark: isDark),
                  ),
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isDark;
  const _OrderCard({required this.order, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surf   = isDark ? AppColors.darkSurface : AppColors.surface;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final txtSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final statusColor = _statusColor(order.status);

    return TapBounce(
      onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: order),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(order.orderNumber, style: AppTextStyles.titleMedium.copyWith(color: txtPri)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${order.statusEmoji} ${order.statusLabel}',
                style: AppTextStyles.labelLarge.copyWith(color: statusColor, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text(_formatDate(order.createdAt), style: AppTextStyles.bodyMedium.copyWith(color: txtSec)),
          const Divider(height: 16),
          ...order.items.take(2).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(item.product.imageUrl, width: 44, height: 44, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 44, height: 44,
                    color: AppColors.primaryLight, child: const Center(child: Text('🌽'))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(item.product.name,
                style: AppTextStyles.bodyMedium.copyWith(color: txtPri),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text('x${item.quantity}', style: AppTextStyles.labelLarge.copyWith(color: txtSec)),
            ]),
          )),
          if (order.items.length > 2)
            Text('+${order.items.length - 2} produk lainnya',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary)),
          const Divider(height: 16),
          Row(children: [
            Text('Total:', style: AppTextStyles.bodyMedium.copyWith(color: txtSec)),
            const SizedBox(width: 6),
            Text(CurrencyFormatter.format(order.total), style: AppTextStyles.priceStyle),
            const Spacer(),
            if (order.status == OrderStatus.shipped || order.status == OrderStatus.processing)
              _ActionBtn(label: 'Lacak', color: AppColors.info,
                onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: order)),
            if (order.status == OrderStatus.delivered)
              _ActionBtn(label: 'Beli Lagi', color: AppColors.secondary, onTap: () {}),
          ]),
        ]),
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:    return AppColors.warning;
      case OrderStatus.confirmed:  return AppColors.info;
      case OrderStatus.processing: return AppColors.primary;
      case OrderStatus.shipped:    return AppColors.secondary;
      case OrderStatus.delivered:  return AppColors.success;
      case OrderStatus.cancelled:  return AppColors.error;
    }
  }

  String _formatDate(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${dt.day} ${m[dt.month-1]} ${dt.year}  •  ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: AppTextStyles.labelLarge.copyWith(color: color, fontWeight: FontWeight.w600)),
    ),
  );
}
