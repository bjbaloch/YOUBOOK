import 'package:flutter/material.dart';
import 'package:youbook/screens/manager/services/manager_services_screen.dart';

class ServiceSuccessLogic {
  static void onOkPressed(BuildContext dialogContext, BuildContext parentContext) {
    Navigator.of(dialogContext).pop();

    Navigator.pushAndRemoveUntil(
      parentContext,
      MaterialPageRoute(
        builder: (context) => const ManagerServicesScreen(),
      ),
      (route) => false, // Remove all previous routes
    );
  }
}
