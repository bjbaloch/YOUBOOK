import 'package:flutter/material.dart';
import 'package:youbook/features/services_details/bus_details/bus_detail_page/UI/bus_detail_ui.dart';
import 'package:youbook/features/services_details/van_details/van_details_page/UI/van_detail_ui.dart';
import 'package:youbook/screens/manager/Home/Data/manager_home_data.dart';
import 'package:youbook/screens/manager/Home/UI/manager_home_ui.dart';

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
      smoothRoute(const ManagerHomeUI(data: const ManagerHomeData())),
    );
    return false;
  }

  static void goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      smoothRoute(const ManagerHomeUI(data: const ManagerHomeData())),
    );
  }

  static void openAddedServices(BuildContext context) {
    Navigator.push(context, smoothRoute(const AddBusDetailsScreen()));
  }

  static void openBusDetails(BuildContext context) {
    Navigator.push(context, smoothRoute(const AddBusDetailsScreen()));
  }

  static void openVanDetails(BuildContext context) {
    Navigator.push(context, smoothRoute(const AddVanDetailsScreen()));
  }
}
