import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/message_model.dart';
import '../controllers/chat_controller.dart';
import '../widgets/animations/animation_widgets.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll ke bawah setiap messages berubah
    ever(Get.find<ChatController>().messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf = isDark ? AppColors.darkSurface : AppColors.surface;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      appBar: _ChatAppBar(ctrl: ctrl, isDark: isDark),
      body: Column(children: [
        // Messages
        Expanded(
          child: Obx(() {
            if (ctrl.isLoadingMsgs.value) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (ctrl.messages.isEmpty) {
              return _EmptyState(conv: ctrl.activeConv.value, isDark: isDark);
            }
            return ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: ctrl.messages.length,
              itemBuilder: (_, i) {
                final msg = ctrl.messages[i];
                final prev = i > 0 ? ctrl.messages[i - 1] : null;
                final showDate =
                    prev == null || !_sameDay(prev.createdAt, msg.createdAt);
                final isMe = msg.senderRole == 'user';
                final showAvatar = !isMe &&
                    (i == ctrl.messages.length - 1 ||
                        ctrl.messages[i + 1].senderRole == 'user');

                return Column(children: [
                  if (showDate)
                    _DateDivider(date: msg.createdAt, isDark: isDark),
                  SlideInWidget(
                    delay: Duration(milliseconds: i < 10 ? 30 * (i % 5) : 0),
                    beginOffset:
                        isMe ? const Offset(0.08, 0) : const Offset(-0.08, 0),
                    duration: const Duration(milliseconds: 280),
                    child: _Bubble(
                      msg: msg,
                      isMe: isMe,
                      showAvatar: showAvatar,
                      isDark: isDark,
                      surf: surf,
                      senderLabel:
                          ctrl.activeConv.value?.displayName ?? 'Penjual',
                    ),
                  ),
                ]);
              },
            );
          }),
        ),

        // Input
        _InputBar(ctrl: ctrl, isDark: isDark, surf: surf),
      ]),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── App Bar ───────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatController ctrl;
  final bool isDark;
  const _ChatAppBar({required this.ctrl, required this.isDark});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final txtPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Obx(() {
      final conv = ctrl.activeConv.value;
      final isSupport = conv == null || !conv.isSellerChat;
      final title = conv?.displayName ?? 'CornMarket Support';
      final avatarEmoji = isSupport ? '🌽' : '🏪';
      final avatarColor =
          isSupport ? AppColors.primary : AppColors.secondaryPale;

      return AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20, color: txtPri),
          onPressed: () {
            ctrl.closeConversation();
            Navigator.of(context).pop();
          },
        ),
        title: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(color: avatarColor, shape: BoxShape.circle),
            child: Center(
                child: Text(avatarEmoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: AppTextStyles.titleMedium.copyWith(color: txtPri)),
            Row(children: [
              Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('Online',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.success, fontSize: 10)),
            ]),
          ]),
        ]),
      );
    });
  }
}

// ── Empty state ───────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final ConversationModel? conv;
  final bool isDark;
  const _EmptyState({required this.conv, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isSupport = conv == null || !conv!.isSellerChat;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleInWidget(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isSupport
                    ? AppColors.primaryLight
                    : AppColors.secondaryPale,
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text(isSupport ? '🌽' : '🏪',
                      style: const TextStyle(fontSize: 36))),
            ),
          ),
          const SizedBox(height: 20),
          Text(isSupport ? 'Chat dengan Support' : 'Chat dengan Penjual',
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            isSupport
                ? 'Ada pertanyaan? Tim CornMarket\nsiap membantu kamu!'
                : 'Tanyakan langsung ke penjual\ntentang produk yang kamu mau.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}

// ── Date Divider ─────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  final bool isDark;
  const _DateDivider({required this.date, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Hari Ini';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Kemarin';
    } else {
      label = DateFormat('d MMM yyyy', 'id').format(date);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(children: [
        Expanded(
            child: Divider(
                color: isDark ? AppColors.darkDivider : AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Text(label, style: AppTextStyles.labelLarge),
          ),
        ),
        Expanded(
            child: Divider(
                color: isDark ? AppColors.darkDivider : AppColors.divider)),
      ]),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe, showAvatar, isDark;
  final Color surf;
  final String senderLabel;

  const _Bubble({
    required this.msg,
    required this.isMe,
    required this.showAvatar,
    required this.isDark,
    required this.surf,
    required this.senderLabel,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(msg.createdAt);

    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        bottom: 2,
        left: isMe ? 56 : 0,
        right: isMe ? 0 : 56,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Seller/support avatar
          if (!isMe) ...[
            if (showAvatar)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: msg.senderRole == 'admin'
                      ? AppColors.primary
                      : AppColors.secondaryPale,
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(
                  msg.senderRole == 'admin' ? '🌽' : '🏪',
                  style: const TextStyle(fontSize: 14),
                )),
              )
            else
              const SizedBox(width: 28),
            const SizedBox(width: 6),
          ],

          // Bubble content
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.68),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : surf,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 4,
                          offset: const Offset(0, 1))
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        if (msg.hasImage)
                          GestureDetector(
                            onTap: () => _viewImage(context, msg.imageUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(
                                    msg.hasContent ? 0 : (isMe ? 16 : 4)),
                                bottomRight: Radius.circular(
                                    msg.hasContent ? 0 : (isMe ? 4 : 16)),
                              ),
                              child: Image.network(
                                msg.imageUrl,
                                width: 220,
                                height: 180,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, prog) => prog == null
                                    ? child
                                    : Container(
                                        width: 220,
                                        height: 180,
                                        color: isDark
                                            ? AppColors.darkSurfaceVariant
                                            : AppColors.surfaceVariant,
                                        child: const Center(
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary))),
                              ),
                            ),
                          ),

                        // Text
                        if (msg.hasContent)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                            child: Text(msg.content,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: isMe
                                      ? AppColors.textPrimary
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary),
                                  height: 1.4,
                                )),
                          ),

                        // Time + tick
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 10, 6),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(time,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe
                                      ? AppColors.textPrimary.withOpacity(0.55)
                                      : (isDark
                                          ? AppColors.darkTextHint
                                          : AppColors.textHint),
                                  fontFamily: 'Poppins',
                                )),
                            if (isMe) ...[
                              const SizedBox(width: 3),
                              Icon(
                                msg.isRead
                                    ? Icons.done_all_rounded
                                    : Icons.done_rounded,
                                size: 13,
                                color: msg.isRead
                                    ? AppColors.secondary
                                    : AppColors.textPrimary.withOpacity(0.45),
                              ),
                            ],
                          ]),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewImage(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(child: InteractiveViewer(child: Image.network(url))),
      ),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final ChatController ctrl;
  final bool isDark;
  final Color surf;
  const _InputBar(
      {required this.ctrl, required this.isDark, required this.surf});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 20,
      ),
      decoration: BoxDecoration(
        color: surf,
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, -3))
        ],
      ),
      child: Row(children: [
        // Photo
        TapBounce(
          onTap: ctrl.pickAndSendImage,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            child: Icon(Icons.image_outlined,
                size: 20,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),

        // Text field
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 120),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            ),
            child: TextField(
              controller: ctrl.textCtrl,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color:
                        isDark ? AppColors.darkTextHint : AppColors.textHint),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Send
        Obx(() => TapBounce(
              onTap: ctrl.isSending.value ? null : ctrl.sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ctrl.isSending.value
                      ? AppColors.primaryLight
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  boxShadow: ctrl.isSending.value
                      ? []
                      : [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                ),
                child: ctrl.isSending.value
                    ? const Center(
                        child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primaryDark)))
                    : const Icon(Icons.send_rounded,
                        size: 18, color: AppColors.textPrimary),
              ),
            )),
      ]),
    );
  }
}
