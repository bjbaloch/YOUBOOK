import 'package:flutter/material.dart';

class ServiceSuccessLogic {
  static void onOkPressed(
    BuildContext dialogContext,
    BuildContext parentContext,
  ) {
    // For passenger-only app, just close the dialog
    Navigator.of(dialogContext).pop();
  }
}
