import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final String messageType; // 'text', 'image', 'location', 'system'
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
  final String conversationType; // 'passenger_driver', 'support', 'group'

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

  final SupabaseClient _supabase = Supabase.instance.client;

  // Stream controllers
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  final StreamController<ChatConversation> _conversationController = StreamController<ChatConversation>.broadcast();
  final StreamController<int> _unreadMessagesController = StreamController<int>.broadcast();

  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<ChatConversation> get conversationStream => _conversationController.stream;
  Stream<int> get unreadMessagesStream => _unreadMessagesController.stream;

  RealtimeChannel? _chatChannel;
  Timer? _typingTimer;
  String? _currentConversationId;

  // Initialize chat service
  Future<void> initializeChat(String userId) async {
    await _initializeRealtimeChannel(userId);
    _updateUnreadMessagesCount(userId);
  }

  // Initialize real-time channel for chat
  Future<void> _initializeRealtimeChannel(String userId) async {
    _chatChannel = _supabase.channel('user_chat_$userId');

    // Listen for new messages
    _chatChannel!.subscribe();

    // Start listening to conversations
    _startConversationUpdates(userId);
  }

  // Start conversation updates
  void _startConversationUpdates(String userId) {
    // Listen for real-time message updates
    _supabase
      .from('chat_messages')
      .stream(primaryKey: ['id'])
      .listen((List<Map<String, dynamic>> data) {
        // Handle new messages
        for (final messageJson in data) {
          final message = ChatMessage.fromJson(messageJson);
          _messageController.add(message);
        }
        _updateUnreadMessagesCount(userId);
      });

    // Listen for conversation updates
    _supabase
      .from('chat_conversations')
      .stream(primaryKey: ['id'])
      .listen((List<Map<String, dynamic>> data) {
        // Handle conversation updates
        for (final conversationJson in data) {
          final conversation = ChatConversation.fromJson(conversationJson);
          _conversationController.add(conversation);
        }
      });

    // Periodic updates as fallback
    Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchConversations(userId);
      _updateUnreadMessagesCount(userId);
    });
  }

  // Send message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String content,
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'receiver_id': receiverId,
        'content': content,
        'message_type': messageType,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };

      await _supabase.from('chat_messages').insert(messageData);

      // Update conversation last activity
      await _updateConversationActivity(conversationId);

      // Send real-time update
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

    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  // Get conversation messages
  Future<List<ChatMessage>> getConversationMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
        .from('chat_messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .limit(limit);

      return response.map((json) => ChatMessage.fromJson(json)).toList().reversed.toList();
    } catch (e) {
      debugPrint('Error getting conversation messages: $e');
      return [];
    }
  }

  // Get user conversations
  Future<List<ChatConversation>> getConversations(String userId) async {
    try {
      final response = await _supabase
        .from('chat_conversations')
        .select('''
          *,
          last_message:chat_messages!inner(
            content,
            created_at,
            sender_name
          )
        ''')
        .or('participant1_id.eq.$userId,participant2_id.eq.$userId')
        .order('last_activity', ascending: false);

      return response.map((json) => ChatConversation.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting conversations: $e');
      return [];
    }
  }

  // Fetch conversations (for periodic updates)
  Future<void> _fetchConversations(String userId) async {
    final conversations = await getConversations(userId);
    for (final conversation in conversations) {
      _conversationController.add(conversation);
    }
  }

  // Create or get conversation
  Future<String> getOrCreateConversation({
    required String participant1Id,
    required String participant1Name,
    required String participant2Id,
    required String participant2Name,
    required String conversationType,
  }) async {
    try {
      // Check if conversation already exists
      final existingResponse = await _supabase
        .from('chat_conversations')
        .select('id')
        .or('and(participant1_id.eq.$participant1Id,participant2_id.eq.$participant2Id),and(participant1_id.eq.$participant2Id,participant2_id.eq.$participant1Id)')
        .maybeSingle();

      if (existingResponse != null) {
        return existingResponse['id'] as String;
      }

      // Create new conversation
      final conversationData = {
        'participant1_id': participant1Id,
        'participant1_name': participant1Name,
        'participant2_id': participant2Id,
        'participant2_name': participant2Name,
        'conversation_type': conversationType,
        'last_activity': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
        .from('chat_conversations')
        .insert(conversationData)
        .select('id')
        .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error creating/getting conversation: $e');
      throw Exception('Failed to create conversation');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _supabase
        .from('chat_messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId);

      _updateUnreadMessagesCount(userId);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Update conversation activity
  Future<void> _updateConversationActivity(String conversationId) async {
    try {
      await _supabase
        .from('chat_conversations')
        .update({'last_activity': DateTime.now().toIso8601String()})
        .eq('id', conversationId);
    } catch (e) {
      debugPrint('Error updating conversation activity: $e');
    }
  }

  // Update unread messages count
  Future<void> _updateUnreadMessagesCount(String userId) async {
    try {
      final response = await _supabase
        .from('chat_messages')
        .select('id')
        .eq('receiver_id', userId)
        .eq('is_read', false);

      final count = response.length;
      _unreadMessagesController.add(count);
    } catch (e) {
      debugPrint('Error updating unread count: $e');
    }
  }

  // Send typing indicator
  Future<void> sendTypingIndicator(String conversationId, String userId, bool isTyping) async {
    try {
      // Cancel existing timer
      _typingTimer?.cancel();

      if (isTyping) {
        // Broadcast typing status
        await _chatChannel?.sendBroadcastMessage(
          event: 'typing',
          payload: {
            'conversationId': conversationId,
            'userId': userId,
            'isTyping': true,
          },
        );

        // Auto-stop typing after 3 seconds
        _typingTimer = Timer(const Duration(seconds: 3), () {
          sendTypingIndicator(conversationId, userId, false);
        });
      } else {
        await _chatChannel?.sendBroadcastMessage(
          event: 'typing',
          payload: {
            'conversationId': conversationId,
            'userId': userId,
            'isTyping': false,
          },
        );
      }
    } catch (e) {
      debugPrint('Error sending typing indicator: $e');
    }
  }

  // Send location in chat
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
      metadata: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // Send system message
  Future<void> sendSystemMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      await _supabase.from('chat_messages').insert({
        'conversation_id': conversationId,
        'sender_id': 'system',
        'sender_name': 'System',
        'receiver_id': 'all',
        'content': content,
        'message_type': 'system',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': true,
      });
    } catch (e) {
      debugPrint('Error sending system message: $e');
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase
        .from('chat_messages')
        .delete()
        .eq('id', messageId);
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  // Report conversation
  Future<void> reportConversation({
    required String conversationId,
    required String reporterId,
    required String reason,
  }) async {
    try {
      await _supabase.from('conversation_reports').insert({
        'conversation_id': conversationId,
        'reporter_id': reporterId,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error reporting conversation: $e');
    }
  }

  // Get online users (for real-time presence)
  Future<List<String>> getOnlineUsers() async {
    try {
      // This would integrate with a presence system
      // For now, return mock data
      return ['user1', 'user2', 'driver1'];
    } catch (e) {
      debugPrint('Error getting online users: $e');
      return [];
    }
  }

  // Set current conversation (for typing indicators)
  void setCurrentConversation(String conversationId) {
    _currentConversationId = conversationId;
  }

  // Stop chat service
  void stopChatService() {
    _chatChannel?.unsubscribe();
    _typingTimer?.cancel();
  }

  // Cleanup
  void dispose() {
    stopChatService();
    _messageController.close();
    _conversationController.close();
    _unreadMessagesController.close();
  }
}
