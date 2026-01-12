import 'package:flutter/material.dart';
import '../../notific_clear_success/clear_success_ui.dart';
import '../../notific_clear_success/clear_success_data.dart';
import '../Data/clear_confirmation_data.dart';

class ClearConfirmationLogic {
  static Future<void> confirmClear(
    BuildContext parentContext,
    ClearConfirmationData data, {
    Duration delay = const Duration(seconds: 3),
  }) async {
    data.isLoading = true;

    // simulate loader
    await Future.delayed(delay);

    // Close the confirmation dialog safely
    Navigator.of(parentContext, rootNavigator: true).pop();

    // Show success dialog
    Future.delayed(const Duration(milliseconds: 120), () {
      showSuccessDialogUI(parentContext, ClearSuccessData());
    });
  }
}