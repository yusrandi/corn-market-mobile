import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/product_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';
import '../controllers/cart_controller.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/chat_controller.dart';
import '../widgets/common/primary_button.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final product = Get.arguments as ProductModel;
    final cart = Get.find<CartController>();
    final favs = Get.find<FavoritesController>();
    final qty = 1.obs;
    final reviews = ReviewRepository.getReviews(product.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Image AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleIconBtn(
                  icon: Icons.arrow_back_ios_rounded, onTap: () => Get.back()),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Obx(() => _CircleIconBtn(
                      icon: favs.isFavorite(product.id)
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      iconColor:
                          favs.isFavorite(product.id) ? AppColors.error : null,
                      onTap: () => favs.toggle(product),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: _CircleIconBtn(icon: Icons.share_outlined, onTap: () {}),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primaryLight,
                    child: const Center(
                        child: Text('🌽', style: TextStyle(fontSize: 80))),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges
                        Row(children: [
                          if (product.isPopular)
                            _Chip('🔥 Populer', AppColors.primary,
                                AppColors.textPrimary),
                          if (product.isNew) ...[
                            if (product.isPopular) const SizedBox(width: 6),
                            _Chip('✨ Baru', AppColors.secondaryPale,
                                AppColors.secondary),
                          ],
                        ]),
                        const SizedBox(height: 10),

                        // Name & Rating row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Text(product.name,
                                    style: AppTextStyles.displayMedium.copyWith(
                                        color: textPri, fontSize: 22))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusSM),
                              ),
                              child: Row(children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.primaryDark, size: 16),
                                const SizedBox(width: 4),
                                Text(product.rating.toStringAsFixed(1),
                                    style: AppTextStyles.titleMedium.copyWith(
                                        color: AppColors.primaryDark)),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                            '${product.reviewCount} ulasan  •  📍 ${product.origin}',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: textSec)),
                        const SizedBox(height: 16),

                        // Price
                        Row(children: [
                          Text(CurrencyFormatter.format(product.price),
                              style: AppTextStyles.priceLarge
                                  .copyWith(color: AppColors.secondary)),
                          Text(' / ${product.unit}',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: textSec)),
                        ]),
                        const SizedBox(height: 4),
                        Text(
                          'Stok: ${product.stock} ${product.unit}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: product.stock < 20
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Qty selector
                        Row(children: [
                          Text('Jumlah:',
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: textPri)),
                          const Spacer(),
                          Obx(() => Row(children: [
                                _QtyBtn(
                                    icon: Icons.remove,
                                    onTap: () {
                                      if (qty.value > 1) qty.value--;
                                    }),
                                SizedBox(
                                  width: 44,
                                  child: Center(
                                      child: Text('${qty.value}',
                                          style: AppTextStyles.titleLarge
                                              .copyWith(color: textPri))),
                                ),
                                _QtyBtn(
                                    icon: Icons.add, onTap: () => qty.value++),
                              ])),
                        ]),
                        const SizedBox(height: 8),
                        Obx(() => Text(
                              'Subtotal: ${CurrencyFormatter.format(product.price * qty.value)}',
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: AppColors.secondary),
                            )),
                      ],
                    ),
                  ),

                  // Divider
                  Divider(
                      height: 1,
                      color:
                          isDark ? AppColors.darkDivider : AppColors.divider),

                  // Description
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deskripsi Produk',
                            style: AppTextStyles.titleLarge
                                .copyWith(color: textPri)),
                        const SizedBox(height: 8),
                        Text(product.description,
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: textSec)),
                        const SizedBox(height: 16),
                        // Info row
                        _InfoRow(
                            label: 'Kategori',
                            value: product.category.capitalizeFirst ??
                                product.category,
                            isDark: isDark),
                        _InfoRow(
                            label: 'Asal',
                            value: product.origin,
                            isDark: isDark),
                        _InfoRow(
                            label: 'Satuan',
                            value: product.unit,
                            isDark: isDark),
                        _InfoRow(
                            label: 'Stok',
                            value: '${product.stock} ${product.unit}',
                            isDark: isDark),
                      ],
                    ),
                  ),

                  Divider(
                      height: 1,
                      color:
                          isDark ? AppColors.darkDivider : AppColors.divider),

                  // Reviews section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('⭐ Ulasan Pembeli',
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: textPri)),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: Text('Lihat Semua',
                                style: AppTextStyles.labelLarge
                                    .copyWith(color: AppColors.secondary)),
                          ),
                        ]),
                        // Rating summary
                        _RatingSummary(product: product, isDark: isDark),
                        const SizedBox(height: 16),
                        ...reviews
                            .map((r) => _ReviewCard(review: r, isDark: isDark)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: surfaceBg,
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: const Offset(0, -4))
          ],
        ),
        child: Obx(() => Row(children: [
              // Wishlist button
              GestureDetector(
                onTap: () => favs.toggle(product),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: favs.isFavorite(product.id)
                        ? AppColors.error.withOpacity(0.1)
                        : (isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: favs.isFavorite(product.id)
                          ? AppColors.error.withOpacity(0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    favs.isFavorite(product.id)
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    color:
                        favs.isFavorite(product.id) ? AppColors.error : textSec,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Chat penjual button — tampil hanya jika ada seller
              if (product.sellerId != null && product.storeId != null) ...[
                GestureDetector(
                  onTap: () async {
                    final chatCtrl = Get.find<ChatController>();
                    final ok = await chatCtrl.startSellerChat(
                      sellerId: product.sellerId!,
                      storeId: product.storeId!,
                    );
                    if (ok) Get.toNamed(AppRoutes.chat);
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryPale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_outlined,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Add to cart
              Expanded(
                child: PrimaryButton(
                  label: 'Tambah ke Keranjang',
                  onPressed: () => cart.addItem(product, quantity: qty.value),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                ),
              ),
            ])),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  const _CircleIconBtn(
      {required this.icon, required this.onTap, this.iconColor});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSurface : AppColors.surface)
              .withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
        ),
        child: Icon(icon,
            size: 18,
            color: iconColor ??
                (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Chip(this.label, this.bg, this.fg);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
        child: Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: fg, fontWeight: FontWeight.w600)),
      );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _InfoRow(
      {required this.label, required this.value, required this.isDark});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary))),
          Text(' : ', style: AppTextStyles.bodyMedium),
          Text(value,
              style: AppTextStyles.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary)),
        ]),
      );
}

class _RatingSummary extends StatelessWidget {
  final ProductModel product;
  final bool isDark;
  const _RatingSummary({required this.product, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      child: Row(children: [
        Column(children: [
          Text(product.rating.toStringAsFixed(1),
              style: AppTextStyles.displayLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary)),
          Row(
              children: List.generate(
                  5,
                  (i) => Icon(
                        i < product.rating.floor()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ))),
          Text('${product.reviewCount} ulasan',
              style: AppTextStyles.labelLarge),
        ]),
        const SizedBox(width: 20),
        Expanded(
            child: Column(
          children: [5, 4, 3, 2, 1].map((star) {
            final pct = star == 5
                ? 0.65
                : star == 4
                    ? 0.25
                    : star == 3
                        ? 0.07
                        : 0.02;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Text('$star', style: AppTextStyles.labelLarge),
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded,
                    color: AppColors.primary, size: 12),
                const SizedBox(width: 6),
                Expanded(
                    child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                )),
              ]),
            );
          }).toList(),
        )),
      ]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isDark;
  const _ReviewCard({required this.review, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(review.userAvatar),
            backgroundColor: AppColors.primaryLight,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text(review.userName,
                      style: AppTextStyles.titleMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary)),
                  if (review.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded,
                        color: AppColors.info, size: 14),
                  ],
                ]),
                Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                              i < review.rating.floor()
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: AppColors.primary,
                              size: 13,
                            ))),
              ])),
          Text(
            _timeAgo(review.createdAt),
            style: AppTextStyles.labelLarge.copyWith(
                color: isDark ? AppColors.darkTextHint : AppColors.textHint),
          ),
        ]),
        const SizedBox(height: 8),
        Text(review.comment,
            style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary)),
        Divider(
            height: 20,
            color: isDark ? AppColors.darkDivider : AppColors.divider),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    return '${diff.inMinutes} menit lalu';
  }
}
