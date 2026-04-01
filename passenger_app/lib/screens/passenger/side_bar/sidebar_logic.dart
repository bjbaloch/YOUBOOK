import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sidebar_data.dart';
import '../../../screens/auth/login/login_screen.dart';

class SidebarLogic {
  final SupabaseClient _sb = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSub;

  SidebarUser? user;
  bool loading = false;
  bool _disposed = false;

  void init(VoidCallback updateUI) {
    _loadUser(updateUI);
    _authSub = _sb.auth.onAuthStateChange.listen((_) => _loadUser(updateUI));
  }

  void dispose() {
    _disposed = true;
    _authSub?.cancel();
  }

  Future<void> _loadUser(VoidCallback updateUI) async {
    if (_disposed) return;

    try {
      final currentUser = _sb.auth.currentUser;
      loading = true;
      if (!_disposed) updateUI();

      if (currentUser == null) {
        user = SidebarUser(displayName: null, email: null, avatarUrl: null);
        loading = false;
        if (!_disposed) updateUI();
        return;
      }

      String? fullName;
      String? avatarUrl;
      String? email;

      try {
        final data = await _sb
            .from('profiles')
            .select('full_name, avatar_url, email')
            .eq('id', currentUser.id)
            .maybeSingle();

        if (data != null) {
          fullName = (data['full_name'] as String?)?.trim();
          avatarUrl = (data['avatar_url'] as String?)?.trim();
          email = (data['email'] as String?)?.trim();
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
      }

      user = SidebarUser(
        displayName: fullName?.isNotEmpty == true ? fullName : 'Name',
        avatarUrl: avatarUrl?.isNotEmpty == true ? avatarUrl : null,
        email: email ?? currentUser.email,
      );

      loading = false;
      if (!_disposed) updateUI();
    } catch (_) {
      loading = false;
      if (!_disposed) updateUI();
    }
  }

  Future<void> logoutWithoutDialog(VoidCallback? onLogout, BuildContext context) async {
    try {
      await _sb.auth.signOut();
      // Navigate to login screen after successful logout
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      if (onLogout != null) onLogout();
    }
  }

  Future<void> logout(VoidCallback? onLogout, BuildContext context) async {
    final result = await showLogoutDialog(context);
    if (result == true) {
      try {
        await _sb.auth.signOut();
      } finally {
        if (onLogout != null) onLogout();
      }
    }
  }

  Future<bool?> showLogoutDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
