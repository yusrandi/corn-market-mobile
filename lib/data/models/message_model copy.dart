class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderRole; // 'user' | 'admin' | 'seller'
  final String content;
  final String imageUrl;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    this.imageUrl = '',
    this.isRead = false,
    required this.createdAt,
  });

  bool get isFromSeller => senderRole == 'seller' || senderRole == 'admin';
  bool get hasImage     => imageUrl.isNotEmpty;
  bool get hasContent   => content.isNotEmpty;

  factory MessageModel.fromMap(Map<String, dynamic> m) => MessageModel(
        id:             m['id'] as String,
        conversationId: m['conversation_id'] as String,
        senderId:       m['sender_id'] as String,
        senderRole:     m['sender_role'] as String? ?? 'user',
        content:        m['content'] as String? ?? '',
        imageUrl:       m['image_url'] as String? ?? '',
        isRead:         m['is_read'] as bool? ?? false,
        createdAt:      DateTime.parse(m['created_at'] as String),
      );
}

class ConversationModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  // Seller chat fields
  final String? sellerId;
  final String? storeId;
  final String storeName;
  final String chatType; // 'support' | 'seller'
  // Common
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadUser;
  final int unreadAdmin;
  final bool isOpen;

  const ConversationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.sellerId,
    this.storeId,
    this.storeName = '',
    this.chatType = 'support',
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadUser  = 0,
    this.unreadAdmin = 0,
    this.isOpen = true,
  });

  bool get isSellerChat => chatType == 'seller';

  /// Label yang tampil di header chat
  String get displayName =>
      isSellerChat ? storeName : 'CornMarket Support';

  factory ConversationModel.fromMap(Map<String, dynamic> m) => ConversationModel(
        id:            m['id'] as String,
        userId:        m['user_id'] as String,
        userName:      m['user_name'] as String? ?? 'Pembeli',
        userAvatar:    m['user_avatar'] as String? ?? '',
        sellerId:      m['seller_id'] as String?,
        storeId:       m['store_id'] as String?,
        storeName:     m['store_name'] as String? ?? '',
        chatType:      m['chat_type'] as String? ?? 'support',
        lastMessage:   m['last_message'] as String? ?? '',
        lastMessageAt: DateTime.parse(m['last_message_at'] as String),
        unreadUser:    m['unread_user'] as int? ?? 0,
        unreadAdmin:   m['unread_admin'] as int? ?? 0,
        isOpen:        m['is_open'] as bool? ?? true,
      );
}
