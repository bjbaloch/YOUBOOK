import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';
import '../models/models.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _applicationsSubscription;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get unread notifications count
  int get unreadNotificationsCount => _notifications.where((n) => n.isRead == false).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize with empty notifications - no mock data
      _notifications = [];
      _unreadCount = 0;

      // Setup real-time subscriptions for admin notifications
      _setupRealtimeSubscriptions();

    } catch (e) {
      _error = e.toString();
      _notifications = [];
      _unreadCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupRealtimeSubscriptions() {
    final supabase = Supabase.instance.client;

    // Listen for new manager applications
    _applicationsSubscription = supabase
        .from('manager_applications')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          _handleNewApplication(data);
        });
  }

  void _handleNewApplication(List<Map<String, dynamic>> applications) {
    // Check for new applications that we haven't notified about yet
    for (final app in applications) {
      final appId = app['id'] as String;
      final status = app['status'] as String;
      final createdAt = DateTime.parse(app['created_at'] as String);

      // Only notify for new applications (created in last 30 seconds to avoid duplicates)
      final isRecent = DateTime.now().difference(createdAt).inSeconds < 30;

      if (isRecent && !_notifications.any((n) => n.id == 'app_$appId')) {
        final userEmail = app['user_email'] as String? ?? 'Unknown User';
        final companyName = app['company_name'] as String;

        // Create admin notification for new application
        final notification = NotificationModel(
          id: 'app_$appId',
          title: 'New Manager Application',
          message: '$userEmail has applied for manager role at $companyName',
          type: 'info',
          isRead: false,
          createdAt: createdAt,
        );

        // Add notification and show push notification
        addNotification(notification);
        NotificationService.showNotification(
          title: notification.title ?? 'New Notification',
          body: notification.message ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    _applicationsSubscription?.cancel();
    super.dispose();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      if (notification.isRead == false) {
        // In a real app, this would call the API to mark as read
        final index = _notifications.indexOf(notification);
        _notifications[index] = NotificationModel(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          data: notification.data,
          isRead: true,
          createdAt: notification.createdAt,
        );

        _unreadCount = unreadNotificationsCount;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // In a real app, this would call the API
      for (int i = 0; i < _notifications.length; i++) {
        if (_notifications[i].isRead == false) {
          _notifications[i] = NotificationModel(
            id: _notifications[i].id,
            userId: _notifications[i].userId,
            title: _notifications[i].title,
            message: _notifications[i].message,
            type: _notifications[i].type,
            data: _notifications[i].data,
            isRead: true,
            createdAt: _notifications[i].createdAt,
          );
        }
      }

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (notification.isRead == false) {
      _unreadCount++;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
