import 'package:flutter/material.dart';
import 'package:youbook/screens/manager/services/manager_services_screen.dart';

class ServiceSuccessLogic {
  static void onOkPressed(
    BuildContext dialogContext,
    BuildContext parentContext,
  ) {
    Navigator.of(dialogContext).pop();

    // Navigate to services screen but keep the manager dashboard in the stack
    Navigator.push(
      parentContext,
      MaterialPageRoute(builder: (context) => const ManagerServicesScreen()),
    );
  }
}
