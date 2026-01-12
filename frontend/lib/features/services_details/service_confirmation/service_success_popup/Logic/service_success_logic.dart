import 'package:flutter/material.dart';
import 'package:youbook/features/add_service/UI/add_service_ui.dart';

class ServiceSuccessLogic {
  static void onOkPressed(BuildContext dialogContext, BuildContext parentContext) {
    Navigator.of(dialogContext).pop();

    Navigator.pushReplacement(
      parentContext,
      MaterialPageRoute(
        builder: (context) => const ServicesPage(),
      ),
    );
  }
}
