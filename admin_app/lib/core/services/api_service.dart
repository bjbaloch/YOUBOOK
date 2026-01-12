import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/models.dart';

class ApiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  ApiService();

  // Admin Stats
  Future<Map<String, dynamic>> getStats() async {
    final stats = <String, dynamic>{};

    // User counts by role
    final usersResponse = await _supabase.from('profiles').select('role');
    final users = usersResponse as List<dynamic>;
    final roleCounts = <String, int>{};
    for (final user in users) {
      final role = user['role'] as String? ?? 'unknown';
      roleCounts[role] = (roleCounts[role] ?? 0) + 1;
    }
    stats['users_by_role'] = roleCounts;

    // Manager applications
    final appsResponse = await _supabase.from('manager_applications').select('status');
    final apps = appsResponse as List<dynamic>;
    final appCounts = <String, int>{};
    for (final app in apps) {
      final status = app['status'] as String? ?? 'unknown';
      appCounts[status] = (appCounts[status] ?? 0) + 1;
    }
    stats['manager_applications'] = appCounts;

    // Total counts (placeholder)
    stats['total_bookings'] = 0;
    stats['total_schedules'] = 0;

    return stats;
  }

  // Users Management
  Future<List<User>> getUsers({
    int skip = 0,
    int limit = 100,
    String? role,
    String? search,
  }) async {
    var query = _supabase.from('profiles').select('*');

    if (role != null) {
      query = query.eq('role', role);
    }

    if (search != null && search.isNotEmpty) {
      query = query.or('email.ilike.%$search%,full_name.ilike.%$search%');
    }

    final response = await query.range(skip, skip + limit - 1);
    final data = response as List<dynamic>;
    return data.map((json) => User.fromJson(json)).toList();
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _supabase.from('profiles').update({'role': role}).eq('id', userId);
  }

  // User Management Actions
  Future<void> suspendUser(String userId) async {
    await _supabase.from('profiles').update({'is_active': false}).eq('id', userId);
  }

  Future<void> activateUser(String userId) async {
    await _supabase.from('profiles').update({'is_active': true}).eq('id', userId);
  }

  Future<void> deleteUser(String userId) async {
    // First delete from profiles (this will cascade to other tables due to foreign keys)
    await _supabase.from('profiles').delete().eq('id', userId);
  }

  Future<void> resetUserPassword(String userId) async {
    // This would typically send a password reset email
    // For Supabase, we can use the admin API to generate a password reset
    final userResponse = await _supabase.from('profiles').select('email').eq('id', userId).single();
    final email = userResponse['email'] as String;

    // Use Supabase admin API to send reset email
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Manager Applications
  Future<List<ManagerApplication>> getManagerApplications({
    String? status,
  }) async {
    var query = _supabase.from('manager_applications').select('*, profiles(email, full_name)');

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query;
    final data = response as List<dynamic>;
    return data.map((json) => ManagerApplication.fromJson(json)).toList();
  }

  Future<void> approveApplication(String applicationId, {String? reviewNotes}) async {
    final updateData = {
      'status': 'approved',
      'reviewed_by': _supabase.auth.currentUser?.id,
      if (reviewNotes != null) 'review_notes': reviewNotes,
    };
    await _supabase.from('manager_applications').update(updateData).eq('id', applicationId);
  }

  Future<void> rejectApplication(String applicationId, {String? reviewNotes}) async {
    final updateData = {
      'status': 'rejected',
      'reviewed_by': _supabase.auth.currentUser?.id,
      if (reviewNotes != null) 'review_notes': reviewNotes,
    };
    await _supabase.from('manager_applications').update(updateData).eq('id', applicationId);
  }

  // Notifications
  Future<void> sendBroadcastNotification(NotificationCreate notification) async {
    // Get all user IDs
    final usersResponse = await _supabase.from('profiles').select('id');
    final userIds = (usersResponse as List<dynamic>).map((u) => u['id'] as String).toList();

    // Insert notifications for all users
    final notificationsData = userIds.map((userId) => {
      'user_id': userId,
      'title': notification.title,
      'message': notification.message,
      'type': notification.type,
      'data': {},
    }).toList();

    await _supabase.from('notifications').insert(notificationsData);
  }

  Future<void> sendUserNotification(String userId, NotificationCreate notification) async {
    // Check if user exists
    final userCheck = await _supabase.from('profiles').select('id').eq('id', userId).maybeSingle();
    if (userCheck == null) {
      throw Exception('User not found');
    }

    final notificationData = {
      'user_id': userId,
      'title': notification.title,
      'message': notification.message,
      'type': notification.type,
      'data': {},
    };

    await _supabase.from('notifications').insert(notificationData);
  }
}
