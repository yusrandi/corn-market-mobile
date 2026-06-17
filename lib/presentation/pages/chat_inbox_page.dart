import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../data/models/message_model.dart';
import '../controllers/chat_controller.dart';
import '../widgets/common/corn_app_bar.dart';
import '../widgets/animations/animation_widgets.dart';

class ChatInboxPage extends StatelessWidget {
  const ChatInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      appBar: const CornAppBar(title: 'Pesan', showBack: false),
      body: Column(children: [
        // ── Chat dengan CornMarket Support ────────────────
        _SupportChatTile(isDark: isDark, ctrl: ctrl),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Chat Penjual',
                style: AppTextStyles.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                )),
          ),
        ),

        // ── Seller conversations ──────────────────────────
        Expanded(
          child: Obx(() {
            if (ctrl.isLoadingConvs.value) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            final sellerConvs =
                ctrl.conversations.where((c) => c.isSellerChat).toList();

            if (sellerConvs.isEmpty) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('💬', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Belum ada chat penjual',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      )),
                  const SizedBox(height: 8),
                  Text('Buka produk dan tap "Chat Penjual"',
                      style: AppTextStyles.bodyMedium),
                ]),
              );
            }

            return ListView.separated(
              itemCount: sellerConvs.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 76,
                color: isDark ? AppColors.darkDivider : AppColors.divider,
              ),
              itemBuilder: (_, i) => SlideInWidget(
                delay: Duration(milliseconds: 60 * i),
                child: _ConvTile(
                  conv: sellerConvs[i],
                  isDark: isDark,
                  ctrl: ctrl,
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

// ── Support chat tile (selalu ada) ────────────────────────────

class _SupportChatTile extends StatelessWidget {
  final bool isDark;
  final ChatController ctrl;
  const _SupportChatTile({required this.isDark, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final surf = isDark ? AppColors.darkSurface : AppColors.surface;

    return Obx(() {
      final supportConv =
          ctrl.conversations.firstWhereOrNull((c) => !c.isSellerChat);
      final unread = supportConv?.unreadUser ?? 0;
      final last = supportConv?.lastMessage ?? 'Tap untuk mulai chat';
      final time =
          supportConv != null ? _formatTime(supportConv.lastMessageAt) : '';

      return TapBounce(
        onTap: () async {
          final ok = await ctrl.startSupportChat();
          if (ok) Get.toNamed(AppRoutes.chat);
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surf,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            boxShadow: [
              BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(children: [
            Stack(children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Center(
                    child: Text('🌽', style: TextStyle(fontSize: 24))),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: surf, width: 2),
                  ),
                ),
              ),
            ]),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Text('CornMarket Support',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontWeight:
                              unread > 0 ? FontWeight.w700 : FontWeight.w600,
                        )),
                    const Spacer(),
                    if (time.isNotEmpty)
                      Text(time,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isDark
                                ? AppColors.darkTextHint
                                : AppColors.textHint,
                          )),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    Expanded(
                        child: Text(last,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: unread > 0
                                  ? (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary)
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                              fontWeight: unread > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    if (unread > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                            color: AppColors.error, shape: BoxShape.circle),
                        child: Center(
                            child: Text('$unread',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700))),
                      ),
                    ],
                  ]),
                ])),
          ]),
        ),
      );
    });
  }
}

// ── Seller conversation tile ──────────────────────────────────

class _ConvTile extends StatelessWidget {
  final ConversationModel conv;
  final bool isDark;
  final ChatController ctrl;
  const _ConvTile(
      {required this.conv, required this.isDark, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final unread = conv.unreadUser;
    return TapBounce(
      onTap: () async {
        await ctrl.openConversation(conv);
        if (ctrl.activeConv.value != null) Get.toNamed(AppRoutes.chat);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          // Store avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondaryPale,
              shape: BoxShape.circle,
            ),
            child:
                const Center(child: Text('🏪', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Expanded(
                      child: Text(conv.storeName,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            fontWeight:
                                unread > 0 ? FontWeight.w700 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                  Text(_formatTime(conv.lastMessageAt),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.darkTextHint
                            : AppColors.textHint,
                      )),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  Expanded(
                      child: Text(conv.lastMessage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: unread > 0
                                ? (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary)
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                            fontWeight:
                                unread > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                  if (unread > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                          color: AppColors.error, shape: BoxShape.circle),
                      child: Center(
                          child: Text('$unread',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700))),
                    ),
                  ],
                ]),
              ])),
        ]),
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'Baru';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}j';
  if (diff.inDays < 7) return '${diff.inDays}h';
  return DateFormat('d MMM').format(dt);
}
