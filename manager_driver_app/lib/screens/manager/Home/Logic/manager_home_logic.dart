import 'package:flutter/material.dart';
import '../../../../core/services/app_router.dart';

class ManagerHomeLogic {
  /// Delegates to the app-wide smooth transition.
  static Route smoothTransition(Widget page) => AppRouter.fade(page);

  static Future<bool> handleBackPress(
    DateTime? lastBackPress,
    BuildContext context,
  ) async {
    final now = DateTime.now();
    if (lastBackPress == null ||
        now.difference(lastBackPress) > const Duration(seconds: 2)) {
      lastBackPress = now;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
      return false;
    }
    return true;
  }
}
