import 'package:youbook/screens/passenger/Home/Data/passenger_home_data.dart';
import 'package:youbook/screens/passenger/Home/UI/passenger_home_ui.dart';
import 'package:flutter/material.dart';


class HelpSupportLogic {
  PageRouteBuilder smoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
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

  Future<bool> handleBackPress(BuildContext context) async {
    Navigator.pushReplacement(context, smoothRoute(const PassengerHomeUI(data: const PassengerHomeData())));
    return false;
  }
}
