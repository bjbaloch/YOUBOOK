import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationData {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;

  const NotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'created_at': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }
}

class RealtimeNotificationService {
  static final RealtimeNotificationService _instance = RealtimeNotificationService._internal();
  factory RealtimeNotificationService() => _instance;
  RealtimeNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;

  RealtimeChannel? _notificationChannel;
  StreamSubscription<RemoteMessage>? _messageSubscription;

  // Notification streams
  final StreamController<NotificationData> _notificationController = StreamController<NotificationData>.broadcast();
  final StreamController<int> _unreadCountController = StreamController<int>.broadcast();

  Stream<NotificationData> get notificationStream => _notificationController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  // Initialize notification services
  Future<void> initialize() async {
    await _initializeFirebaseMessaging();
    await _initializeLocalNotifications();
    await _initializeRealtimeChannel();
    _updateUnreadCount();
  }

  // Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Firebase messaging authorized');

      // Get FCM token
      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await _saveFCMToken(fcmToken);
      }

      // Listen to token updates
      _firebaseMessaging.onTokenRefresh.listen(_saveFCMToken);

      // Listen to foreground messages
      _messageSubscription = FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Initialize real-time channel
  Future<void> _initializeRealtimeChannel() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _notificationChannel = _supabase.channel('user_notifications_$userId');
    await _notificationChannel!.subscribe();
  }

  // Handle foreground messages
  void _onForegroundMessage(RemoteMessage message) {
    final notificationData = NotificationData(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      data: message.data,
      timestamp: DateTime.now(),
    );

    _notificationController.add(notificationData);
    _showLocalNotification(notificationData);
    _updateUnreadCount();
  }

  // Background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background messages
    debugPrint('Background message: ${message.notification?.title}');
  }

  // Save FCM token to database
  Future<void> _saveFCMToken(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('user_fcm_tokens').upsert({
        'user_id': userId,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(NotificationData notification) async {
    const androidDetails = AndroidNotificationDetails(
      'youbook_channel',
      'YOUBOOK Notifications',
      channelDescription: 'Notifications for YOUBOOK app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.data),
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        _handleNotificationAction(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  // Handle notification actions
  void _handleNotificationAction(Map<String, dynamic> data) {
    final action = data['action'];
    final bookingId = data['booking_id'];

    switch (action) {
      case 'view_booking':
        if (bookingId != null) {
          // Navigate to booking details
          debugPrint('Navigate to booking: $bookingId');
        }
        break;
      case 'view_trip':
        if (bookingId != null) {
          // Navigate to trip tracking
          debugPrint('Navigate to trip: $bookingId');
        }
        break;
      default:
        debugPrint('Unknown notification action: $action');
    }
  }

  // Send notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'data': data,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  // Send push notification via FCM
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final tokenResponse = await _supabase
        .from('user_fcm_tokens')
        .select('fcm_token')
        .eq('user_id', userId)
        .single();

      final fcmToken = tokenResponse['fcm_token'] as String?;

      if (fcmToken != null) {
        // Send via FCM (in production, this would be done via your backend)
        await _sendFCMMessage(fcmToken, title, body, data);
      }
    } catch (e) {
      debugPrint('Error sending push notification: $e');
    }
  }

  // Send FCM message (simplified - in production use backend)
  Future<void> _sendFCMMessage(String token, String title, String body, Map<String, dynamic>? data) async {
    // This is a simplified version. In production, use your backend API
    debugPrint('Sending FCM message to $token: $title - $body');
  }

  // Get notifications
  Future<List<NotificationData>> getNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      dynamic query = _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      query = query.order('created_at', ascending: false).limit(limit);

      final response = await query;
      return response.map((json) => NotificationData.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);

      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);

      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Update unread count
  Future<void> _updateUnreadCount() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

      final count = response.length;
      _unreadCountController.add(count);
    } catch (e) {
      debugPrint('Error updating unread count: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
        .from('notifications')
        .delete()
        .eq('id', notificationId);

      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  // Cleanup
  void dispose() {
    _notificationChannel?.unsubscribe();
    _messageSubscription?.cancel();
    _notificationController.close();
    _unreadCountController.close();
  }
}
