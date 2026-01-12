import 'package:flutter/material.dart';
import '../../../Home/UI/manager_home_ui.dart';
import '../../../Home/Data/manager_home_data.dart';
import '../../../../passenger/Notification/notific_clear/UI/clear_confirmation_ui.dart';
import '../../../../../core/services/role_based_navigation_service.dart';

class ManagerNotificationsLogic {
  // Smooth transition to ManagerHome
  static Route createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ManagerHomeUI(data: ManagerHomeData()),
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
    final navigationService = RoleBasedNavigationService();
    await navigationService.navigateToAppropriateDashboard(context, replace: true);
    return false;
  }

  // Show confirmation to clear notifications
  static void showClearDialog(BuildContext context) {
    showClearConfirmationDialog(context);
  }
}
