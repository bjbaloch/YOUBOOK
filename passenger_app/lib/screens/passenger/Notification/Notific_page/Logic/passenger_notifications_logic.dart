import 'package:flutter/material.dart';
import '../../../Home/UI/passenger_home_ui.dart';
import '../../../Home/Data/passenger_home_data.dart';
import '../../notific_clear/UI/clear_confirmation_ui.dart';

class PassengerNotificationsLogic {
  // Smooth transition to PassengerHome
  static Route createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const PassengerHomeUI(data: PassengerHomeData()),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(-0.2, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        final fadeAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }

  // Handle back press
  static Future<bool> handleBackPress(BuildContext context) async {
    Navigator.of(context).pushReplacement(createRoute());
    return false;
  }

  // Show confirmation to clear notifications
  static void showClearDialog(BuildContext context) {
    showClearConfirmationDialog(context);
  }
}
