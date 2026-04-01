import 'package:flutter/material.dart';
import '../../screens/auth/login/login_screen.dart';
import '../services/app_router.dart';

// TODO: Restore full implementation when connecting backend.
class RoleBasedNavigationService {
  static final RoleBasedNavigationService _instance =
      RoleBasedNavigationService._internal();
  factory RoleBasedNavigationService() => _instance;
  RoleBasedNavigationService._internal();

  Future<void> navigateToAppropriateDashboard(
    BuildContext context, {
    bool replace = false,
  }) async {
    // UI-only mode: always go to login
    _navigate(context, const LoginScreen(), replace);
  }

  void _navigate(BuildContext context, Widget screen, bool replace) {
    if (replace) {
      AppRouter.replace(context, screen);
    } else {
      AppRouter.replaceAll(context, screen);
    }
  }

  Future<bool> handleBackPress(BuildContext context) async {
    await navigateToAppropriateDashboard(context, replace: true);
    return false;
  }
}
