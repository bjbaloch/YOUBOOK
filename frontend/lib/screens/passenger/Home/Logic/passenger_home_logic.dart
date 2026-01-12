import 'package:flutter/material.dart';
import '../../../../core/services/role_based_navigation_service.dart';

class PassengerHomeLogic {
  static Route smoothTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;
        final tween = Tween(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }

  static Future<bool> handleBackPress(
    DateTime? lastBackPress,
    BuildContext context,
  ) async {
    // Use role-based navigation instead of exit
    final navigationService = RoleBasedNavigationService();

    // If on dashboard, allow exit after confirmation
    if (navigationService.isOnDashboard(context)) {
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
    } else {
      // If not on dashboard, navigate to appropriate dashboard
      await navigationService.handleBackPress(context);
      return false;
    }
  }
}
