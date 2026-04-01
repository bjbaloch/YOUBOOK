import 'package:flutter/material.dart';
import '../UI/add_service_ui.dart';

class ServicesLogic {
  /// Smooth Route Transition
  static PageRouteBuilder smoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide =
            Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  /// Navigation Logic
  static Future<bool> onWillPop(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      smoothRoute(const ServicesPage()),
    );
    return false;
  }

  static void goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      smoothRoute(const ServicesPage()),
    );
  }

  static void openAddedServices(BuildContext context) {
    // Navigate back to add service screen
    Navigator.pushReplacement(
      context,
      smoothRoute(const ServicesPage()),
    );
  }

  static void openBusDetails(BuildContext context) {
    // TODO: Implement bus details navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bus details feature coming soon')),
    );
  }

  static void openVanDetails(BuildContext context) {
    // TODO: Implement van details navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Van details feature coming soon')),
    );
  }
}
