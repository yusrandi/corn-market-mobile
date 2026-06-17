import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../controllers/main_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/chat_controller.dart';
import 'home_page.dart';
import 'category_page.dart';
import 'cart_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MainController>();
    final cart = Get.find<CartController>();
    final chat = Get.find<ChatController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf = isDark ? AppColors.darkSurface : AppColors.surface;

    const pages = [
      HomePage(),
      CategoryPage(),
      CartPage(),
      OrdersPage(),
      ProfilePage(),
    ];

    final navItems = [
      (Icons.home_rounded, Icons.home_outlined, 'Beranda'),
      (Icons.category_rounded, Icons.category_outlined, 'Kategori'),
      (Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 'Keranjang'),
      (Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Pesanan'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: ctrl.selectedIndex.value,
            children: pages,
          )),

      // Floating chat button
      floatingActionButton: Obx(() => Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                onPressed: () => Get.toNamed(AppRoutes.chatInbox),
                backgroundColor: AppColors.secondary,
                elevation: 4,
                child: const Icon(Icons.chat_rounded,
                    color: Colors.white, size: 22),
              ),
              if (chat.totalUnread.value > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle),
                    child: Center(
                        child: Text(
                      '${chat.totalUnread.value > 9 ? "9+" : chat.totalUnread.value}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    )),
                  ),
                ),
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surf,
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(navItems.length, (i) {
                    final item = navItems[i];
                    final selected = ctrl.selectedIndex.value == i;
                    final isCart = i == 2;

                    return GestureDetector(
                      onTap: () => ctrl.changePage(i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMD),
                        ),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          isCart
                              ? Obx(() =>
                                  Stack(clipBehavior: Clip.none, children: [
                                    Icon(selected ? item.$1 : item.$2,
                                        size: 24,
                                        color: selected
                                            ? AppColors.primaryDark
                                            : (isDark
                                                ? AppColors.darkTextHint
                                                : AppColors.textHint)),
                                    if (cart.itemCount > 0)
                                      Positioned(
                                          top: -6,
                                          right: -6,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle),
                                            child: Center(
                                                child: Text(
                                                    '${cart.itemCount > 9 ? "9+" : cart.itemCount}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w700))),
                                          )),
                                  ]))
                              : Icon(selected ? item.$1 : item.$2,
                                  size: 24,
                                  color: selected
                                      ? AppColors.primaryDark
                                      : (isDark
                                          ? AppColors.darkTextHint
                                          : AppColors.textHint)),
                          const SizedBox(height: 2),
                          Text(item.$3,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? AppColors.primaryDark
                                    : (isDark
                                        ? AppColors.darkTextHint
                                        : AppColors.textHint),
                              )),
                        ]),
                      ),
                    );
                  }),
                )),
          ),
        ),
      ),
    );
  }
}
