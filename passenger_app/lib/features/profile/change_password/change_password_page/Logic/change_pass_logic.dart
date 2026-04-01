import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youbook/features/profile/change_password/change_password_page/Data/change_pass_data.dart';

class ChangePasswordLogic {
  final ChangePasswordData data;

  ChangePasswordLogic({required this.data});

  // Password validation regex
  bool validatePassword(String pass) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return regex.hasMatch(pass);
  }

  // Validate all fields
  void validateFields(VoidCallback updateUI, {bool fromButton = false}) {
    final oldPass = data.oldPasswordCtrl.text.trim();
    final newPass = data.newPasswordCtrl.text.trim();
    final confirmPass = data.confirmPasswordCtrl.text.trim();

    data.oldPassError = (fromButton && oldPass.isEmpty)
        ? "Old password required"
        : null;

    if (data.touchedNew || fromButton) {
      if (newPass.isEmpty) {
        data.newPassError = "New password required";
      } else if (!validatePassword(newPass)) {
        data.newPassError =
            "Must have 8+ chars, upper, lower, number & special char";
      } else {
        data.newPassError = null;
      }
    }

    if (data.touchedConfirm || fromButton) {
      if (confirmPass.isEmpty) {
        data.confirmPassError = "Confirm password required";
      } else if (confirmPass != newPass) {
        data.confirmPassError = "Passwords do not match";
      } else {
        data.confirmPassError = null;
      }
    }

    updateUI();
  }

  // Update password process
  void updatePassword(
    BuildContext context,
    VoidCallback updateUI,
    VoidCallback onSuccess,
  ) {
    validateFields(updateUI, fromButton: true);

    if (data.oldPassError != null ||
        data.newPassError != null ||
        data.confirmPassError != null)
      return;

    data.isLoading = true;
    updateUI();

    Future.delayed(const Duration(seconds: 2), () {
      data.isLoading = false;
      updateUI();
      if (!context.mounted) return;

      onSuccess();
    });
  }

  void dispose() {
    data.oldPasswordCtrl.dispose();
    data.newPasswordCtrl.dispose();
    data.confirmPasswordCtrl.dispose();
  }
}
