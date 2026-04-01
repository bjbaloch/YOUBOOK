import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  StreamSubscription<RemoteMessage>? _messageSubscription;

  final StreamController<NotificationData> _notificationController = StreamController<NotificationData>.broadcast();
  final StreamController<int> _unreadCountController = StreamController<int>.broadcast();

  Stream<NotificationData> get notificationStream => _notificationController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  Future<void> initialize() async {
    await _initializeFirebaseMessaging();
    await _initializeLocalNotifications();
    // TODO: Restore Supabase realtime channel when connecting backend
  }

  Future<void> _initializeFirebaseMessaging() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Firebase messaging authorized');

      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await _saveFCMToken(fcmToken);
      }

      _firebaseMessaging.onTokenRefresh.listen(_saveFCMToken);
      _messageSubscription = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

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
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Background message: ${message.notification?.title}');
  }

  Future<void> _saveFCMToken(String token) async {
    // TODO: Restore Supabase upsert when connecting backend
    debugPrint('FCM token (UI-only mode): $token');
  }

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
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.data),
    );
  }

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

  void _handleNotificationAction(Map<String, dynamic> data) {
    final action = data['action'];
    final bookingId = data['booking_id'];

    switch (action) {
      case 'view_booking':
        if (bookingId != null) debugPrint('Navigate to booking: $bookingId');
        break;
      case 'view_trip':
        if (bookingId != null) debugPrint('Navigate to trip: $bookingId');
        break;
      default:
        debugPrint('Unknown notification action: $action');
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // TODO: Restore Supabase insert when connecting backend
    debugPrint('sendNotification skipped in UI-only mode');
  }

  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // TODO: Restore Supabase FCM token lookup when connecting backend
    debugPrint('sendPushNotification skipped in UI-only mode');
  }

  Future<List<NotificationData>> getNotifications({int limit = 50, bool unreadOnly = false}) async {
    // TODO: Restore Supabase query when connecting backend
    return [];
  }

  Future<void> markAsRead(String notificationId) async {
    // TODO: Restore Supabase update when connecting backend
  }

  Future<void> markAllAsRead() async {
    // TODO: Restore Supabase update when connecting backend
  }

  Future<void> deleteNotification(String notificationId) async {
    // TODO: Restore Supabase delete when connecting backend
  }

  void dispose() {
    _messageSubscription?.cancel();
    _notificationController.close();
    _unreadCountController.close();
  }
}
