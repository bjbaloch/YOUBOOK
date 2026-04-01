import 'dart:async';
import 'package:flutter/foundation.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final String messageType;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    required this.messageType,
    required this.timestamp,
    required this.isRead,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      timestamp: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'receiver_id': receiverId,
      'content': content,
      'message_type': messageType,
      'created_at': timestamp.toIso8601String(),
      'is_read': isRead,
      'metadata': metadata,
    };
  }
}

class ChatConversation {
  final String conversationId;
  final String participant1Id;
  final String participant1Name;
  final String participant2Id;
  final String participant2Name;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;
  final String conversationType;

  const ChatConversation({
    required this.conversationId,
    required this.participant1Id,
    required this.participant1Name,
    required this.participant2Id,
    required this.participant2Name,
    this.lastMessage,
    required this.unreadCount,
    required this.lastActivity,
    required this.conversationType,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      conversationId: json['id'] as String,
      participant1Id: json['participant1_id'] as String,
      participant1Name: json['participant1_name'] as String,
      participant2Id: json['participant2_id'] as String,
      participant2Name: json['participant2_name'] as String,
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      lastActivity: DateTime.parse(json['last_activity'] as String),
      conversationType: json['conversation_type'] as String? ?? 'passenger_driver',
    );
  }
}

class RealtimeChatService {
  static final RealtimeChatService _instance = RealtimeChatService._internal();
  factory RealtimeChatService() => _instance;
  RealtimeChatService._internal();

  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  final StreamController<ChatConversation> _conversationController = StreamController<ChatConversation>.broadcast();
  final StreamController<int> _unreadMessagesController = StreamController<int>.broadcast();

  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<ChatConversation> get conversationStream => _conversationController.stream;
  Stream<int> get unreadMessagesStream => _unreadMessagesController.stream;

  Timer? _typingTimer;
  String? _currentConversationId;

  Future<void> initializeChat(String userId) async {
    // TODO: Restore Supabase realtime channel when connecting backend
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String content,
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    // TODO: Restore Supabase insert when connecting backend
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      content: content,
      messageType: messageType,
      timestamp: DateTime.now(),
      isRead: false,
      metadata: metadata,
    );
    _messageController.add(message);
  }

  Future<List<ChatMessage>> getConversationMessages(String conversationId, {int limit = 50}) async {
    // TODO: Restore Supabase query when connecting backend
    return [];
  }

  Future<List<ChatConversation>> getConversations(String userId) async {
    // TODO: Restore Supabase query when connecting backend
    return [];
  }

  Future<String> getOrCreateConversation({
    required String participant1Id,
    required String participant1Name,
    required String participant2Id,
    required String participant2Name,
    required String conversationType,
  }) async {
    // TODO: Restore Supabase query when connecting backend
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    // TODO: Restore Supabase update when connecting backend
  }

  Future<void> sendTypingIndicator(String conversationId, String userId, bool isTyping) async {
    _typingTimer?.cancel();
    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        sendTypingIndicator(conversationId, userId, false);
      });
    }
  }

  Future<void> sendLocationMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required double latitude,
    required double longitude,
  }) async {
    await sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      content: '📍 Location shared',
      messageType: 'location',
      metadata: {'latitude': latitude, 'longitude': longitude},
    );
  }

  Future<void> sendSystemMessage({required String conversationId, required String content}) async {
    // TODO: Restore Supabase insert when connecting backend
    debugPrint('System message (UI-only): $content');
  }

  Future<void> deleteMessage(String messageId) async {
    // TODO: Restore Supabase delete when connecting backend
  }

  Future<void> reportConversation({
    required String conversationId,
    required String reporterId,
    required String reason,
  }) async {
    // TODO: Restore Supabase insert when connecting backend
  }

  Future<List<String>> getOnlineUsers() async {
    return [];
  }

  void setCurrentConversation(String conversationId) {
    _currentConversationId = conversationId;
  }

  void stopChatService() {
    _typingTimer?.cancel();
  }

  void dispose() {
    stopChatService();
    _messageController.close();
    _conversationController.close();
    _unreadMessagesController.close();
  }
}
