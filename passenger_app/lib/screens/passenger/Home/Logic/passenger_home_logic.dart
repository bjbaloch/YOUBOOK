import 'package:flutter/material.dart';

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
    // Simple back press handling - allow exit after double tap
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
