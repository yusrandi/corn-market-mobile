import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatRepository {
  final _db = Supabase.instance.client;
  static const _bucket = 'chat-images';

  // ── Support chat ──────────────────────────────────────────

  Future<String> getOrCreateSupportConversation(String userId) async {
    final result = await _db.rpc(
      'get_or_create_conversation',
      params: {'p_user_id': userId},
    );
    return result as String;
  }

  // ── Seller chat ───────────────────────────────────────────

  Future<String> getOrCreateSellerConversation({
    required String buyerId,
    required String sellerId,
    required String storeId,
  }) async {
    final result = await _db.rpc(
      'get_or_create_seller_conversation',
      params: {
        'p_buyer_id': buyerId,
        'p_seller_id': sellerId,
        'p_store_id': storeId,
      },
    );
    return result as String;
  }

  // ── Get conversations (fetch, bukan stream) ───────────────
  // Bug fix: Supabase .stream().eq() hanya untuk primary key
  // Gunakan fetch manual + polling/realtime channel

  Future<List<ConversationModel>> getMyConversations(String userId) async {
    final data = await _db
        .from('conversations')
        .select()
        .eq('user_id', userId)
        .order('last_message_at', ascending: false);
    return (data as List).map((m) => ConversationModel.fromMap(m)).toList();
  }

  // ── Watch conversations via Realtime Broadcast ────────────
  // Fix: pakai postgres_changes bukan .stream() untuk filter non-PK

  Stream<List<ConversationModel>> watchMyConversations(String userId) {
    // StreamController untuk emit ulang setiap ada perubahan
    late StreamController<List<ConversationModel>> controller;
    RealtimeChannel? channel;

    Future<void> fetch() async {
      try {
        final list = await getMyConversations(userId);
        if (!controller.isClosed) controller.add(list);
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    controller = StreamController<List<ConversationModel>>(
      onListen: () async {
        // Fetch langsung pertama kali
        await fetch();

        // Subscribe realtime perubahan conversations
        channel = _db
            .channel('conversations:$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'conversations',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: userId,
              ),
              callback: (_) => fetch(),
            )
            .subscribe();
      },
      onCancel: () {
        channel?.unsubscribe();
        controller.close();
      },
    );

    return controller.stream;
  }

  // ── Get messages ─────────────────────────────────────────

  Future<List<MessageModel>> getMessages(
    String conversationId, {
    int limit = 60,
  }) async {
    final data = await _db
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List)
        .map((m) => MessageModel.fromMap(m))
        .toList()
        .reversed
        .toList();
  }

  // ── Watch messages via Realtime ───────────────────────────

  Stream<List<MessageModel>> watchMessages(String conversationId) {
    late StreamController<List<MessageModel>> controller;
    RealtimeChannel? channel;
    List<MessageModel> _cache = [];

    Future<void> fetchAll() async {
      try {
        final list = await getMessages(conversationId);
        _cache = list;
        if (!controller.isClosed) controller.add(list);
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    controller = StreamController<List<MessageModel>>(
      onListen: () async {
        await fetchAll();

        channel = _db
            .channel('messages:$conversationId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'conversation_id',
                value: conversationId,
              ),
              callback: (payload) {
                // Tambah pesan baru ke cache tanpa re-fetch semua
                try {
                  final newMsg = MessageModel.fromMap(
                    Map<String, dynamic>.from(payload.newRecord),
                  );
                  // Cegah duplikat
                  if (!_cache.any((m) => m.id == newMsg.id)) {
                    _cache = [..._cache, newMsg];
                    if (!controller.isClosed) controller.add(_cache);
                  }
                } catch (_) {
                  // fallback ke fetch ulang
                  fetchAll();
                }
              },
            )
            .subscribe();
      },
      onCancel: () {
        channel?.unsubscribe();
        controller.close();
      },
    );

    return controller.stream;
  }

  // ── Send text ─────────────────────────────────────────────

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String senderRole = 'user',
  }) async {
    await _db.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_role': senderRole,
      'content': content.trim(),
      'image_url': '',
    });
  }

  // ── Send image ────────────────────────────────────────────

  Future<void> sendImage({
    required String conversationId,
    required String senderId,
    required String filePath,
    String senderRole = 'user',
  }) async {
    final file = File(filePath);
    final ext = filePath.split('.').last;
    final storagePath =
        '$conversationId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _db.storage.from(_bucket).upload(storagePath, file);
    final imageUrl = _db.storage.from(_bucket).getPublicUrl(storagePath);

    await _db.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_role': senderRole,
      'content': '',
      'image_url': imageUrl,
    });
  }

  // ── Mark as read ──────────────────────────────────────────

  Future<void> markAsRead(String conversationId, String role) async {
    try {
      final oppositeRole = role == 'user' ? 'seller' : 'user';
      await _db
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .eq('sender_role', oppositeRole)
          .eq('is_read', false);

      final field = role == 'user' ? 'unread_user' : 'unread_admin';
      await _db
          .from('conversations')
          .update({field: 0}).eq('id', conversationId);
    } catch (_) {
      // non-critical, ignore
    }
  }

  // ── Total unread (polling via stream) ─────────────────────

  Stream<int> watchTotalUnread(String userId) {
    late StreamController<int> controller;
    RealtimeChannel? channel;

    Future<void> fetch() async {
      try {
        final data = await _db
            .from('conversations')
            .select('unread_user')
            .eq('user_id', userId);
        final total = (data as List)
            .fold<int>(0, (s, r) => s + ((r['unread_user'] as int?) ?? 0));
        if (!controller.isClosed) controller.add(total);
      } catch (_) {}
    }

    controller = StreamController<int>(
      onListen: () async {
        await fetch();
        channel = _db
            .channel('unread:$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'conversations',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: userId,
              ),
              callback: (_) => fetch(),
            )
            .subscribe();
      },
      onCancel: () {
        channel?.unsubscribe();
        controller.close();
      },
    );

    return controller.stream;
  }
}
