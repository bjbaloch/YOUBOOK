import 'package:flutter/material.dart';

/// Single source of truth for all navigation transitions in the app.
class AppRouter {
  AppRouter._();

  static const Duration _duration = Duration(milliseconds: 380);
  static const Duration _reverseDuration = Duration(milliseconds: 300);

  /// Fade + subtle upward slide — used for every push/replace in the app.
  static PageRouteBuilder<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: _duration,
      reverseTransitionDuration: _reverseDuration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  /// Push a new screen.
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(fade(page));
  }

  /// Replace current screen.
  static Future<T?> replace<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement<T, dynamic>(fade(page));
  }

  /// Clear entire stack and push.
  static Future<T?> replaceAll<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      fade(page),
      (route) => false,
    );
  }
}
