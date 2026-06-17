import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'auth_controller.dart';

class ChatController extends GetxController {
  final ChatRepository _repo = ChatRepository();

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final Rx<ConversationModel?> activeConv = Rx<ConversationModel?>(null);

  final RxBool isLoadingConvs = true.obs;
  final RxBool isLoadingMsgs = false.obs;
  final RxBool isSending = false.obs;
  final RxInt totalUnread = 0.obs;

  final textCtrl = TextEditingController();

  StreamSubscription<List<ConversationModel>>? _convSub;
  StreamSubscription<List<MessageModel>>? _msgSub;
  StreamSubscription<int>? _unreadSub;

  // ── Bug fix: userId mungkin kosong saat onInit karena user belum login
  // Gunakan worker untuk tunggu userId ready

  @override
  void onInit() {
    super.onInit();
    // Langsung init jika sudah login
    final uid = _userId;
    if (uid.isNotEmpty) {
      _initForUser(uid);
    } else {
      // Tunggu sampai user login
      final auth = Get.find<AuthController>();
      ever(auth.currentUser, (user) {
        if (user != null && _convSub == null) {
          _initForUser(user.id);
        }
      });
    }
  }

  String get _userId => Get.find<AuthController>().currentUser.value?.id ?? '';

  void _initForUser(String uid) {
    _watchConversations(uid);
    _watchUnread(uid);
  }

  @override
  void onClose() {
    _convSub?.cancel();
    _msgSub?.cancel();
    _unreadSub?.cancel();
    textCtrl.dispose();
    super.onClose();
  }

  // ── Watch conversations ───────────────────────────────────

  void _watchConversations(String uid) {
    isLoadingConvs.value = true;
    _convSub?.cancel();
    _convSub = _repo.watchMyConversations(uid).listen(
      (list) {
        conversations.assignAll(list);
        isLoadingConvs.value = false;
      },
      onError: (_) {
        isLoadingConvs.value = false;
      },
    );
  }

  void _watchUnread(String uid) {
    _unreadSub?.cancel();
    _unreadSub = _repo.watchTotalUnread(uid).listen((n) {
      totalUnread.value = n;
    });
  }

  // ── Refresh conversations manual ──────────────────────────

  Future<void> refreshConversations() async {
    final uid = _userId;
    if (uid.isEmpty) return;
    try {
      final list = await _repo.getMyConversations(uid);
      conversations.assignAll(list);
    } catch (_) {}
  }

  // ── Open conversation ─────────────────────────────────────

  Future<void> openConversation(ConversationModel conv) async {
    activeConv.value = conv;
    isLoadingMsgs.value = true;
    messages.clear();

    try {
      // Fetch awal
      final msgs = await _repo.getMessages(conv.id);
      messages.assignAll(msgs);
    } catch (_) {}

    isLoadingMsgs.value = false;

    // Subscribe realtime (terpisah dari loading)
    _msgSub?.cancel();
    _msgSub = _repo.watchMessages(conv.id).listen(
      (newMsgs) {
        messages.assignAll(newMsgs);
      },
      onError: (_) {},
    );

    // Mark read non-blocking
    _repo.markAsRead(conv.id, 'user');
  }

  // ── Start support chat ────────────────────────────────────

  Future<bool> startSupportChat() async {
    final uid = _userId;
    if (uid.isEmpty) return false;

    isLoadingMsgs.value = true;
    try {
      final convId = await _repo.getOrCreateSupportConversation(uid);

      // Cari di cache dulu, fallback ke fetch
      var conv = conversations.firstWhereOrNull((c) => c.id == convId);
      if (conv == null) {
        await refreshConversations();
        conv = conversations.firstWhereOrNull((c) => c.id == convId);
      }

      if (conv != null) {
        await openConversation(conv);
        return true;
      }
      return false;
    } catch (e) {
      isLoadingMsgs.value = false;
      Get.snackbar('Error', 'Gagal membuka chat support',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
      return false;
    }
  }

  // ── Start seller chat ─────────────────────────────────────

  Future<bool> startSellerChat({
    required String sellerId,
    required String storeId,
  }) async {
    final uid = _userId;
    if (uid.isEmpty) return false;

    isLoadingMsgs.value = true;
    try {
      final convId = await _repo.getOrCreateSellerConversation(
        buyerId: uid,
        sellerId: sellerId,
        storeId: storeId,
      );

      var conv = conversations.firstWhereOrNull((c) => c.id == convId);
      if (conv == null) {
        await refreshConversations();
        conv = conversations.firstWhereOrNull((c) => c.id == convId);
      }

      if (conv != null) {
        await openConversation(conv);
        return true;
      }
      return false;
    } catch (e) {
      isLoadingMsgs.value = false;
      Get.snackbar('Error', 'Gagal membuka chat penjual',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
      return false;
    }
  }

  // ── Send text ─────────────────────────────────────────────
  // Bug fix: clear text SETELAH berhasil kirim, bukan sebelumnya

  Future<void> sendMessage() async {
    final text = textCtrl.text.trim();
    final conv = activeConv.value;
    if (text.isEmpty || conv == null || isSending.value) return;

    isSending.value = true;
    try {
      await _repo.sendMessage(
        conversationId: conv.id,
        senderId: _userId,
        content: text,
        senderRole: 'user',
      );
      // Clear SETELAH berhasil
      textCtrl.clear();
    } catch (_) {
      // Teks TIDAK di-clear jika gagal, user bisa retry
      Get.snackbar(
        'Gagal',
        'Pesan gagal dikirim. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSending.value = false;
    }
  }

  // ── Send image ────────────────────────────────────────────

  Future<void> pickAndSendImage() async {
    final conv = activeConv.value;
    if (conv == null || isSending.value) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;

    isSending.value = true;
    try {
      await _repo.sendImage(
        conversationId: conv.id,
        senderId: _userId,
        filePath: picked.path,
        senderRole: 'user',
      );
    } catch (_) {
      Get.snackbar(
        'Gagal',
        'Foto gagal dikirim. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSending.value = false;
    }
  }

  // ── Close active conversation ────────────────────────────

  void closeConversation() {
    _msgSub?.cancel();
    _msgSub = null;
    activeConv.value = null;
    messages.clear();
  }
}
