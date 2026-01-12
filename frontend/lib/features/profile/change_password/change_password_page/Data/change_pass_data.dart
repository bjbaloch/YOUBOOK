import 'package:flutter/material.dart';

class ChangePasswordData {
  final TextEditingController oldPasswordCtrl;
  final TextEditingController newPasswordCtrl;
  final TextEditingController confirmPasswordCtrl;

  bool obscureOld;
  bool obscureNew;
  bool obscureConfirm;

  bool isLoading;

  String? oldPassError;
  String? newPassError;
  String? confirmPassError;

  bool touchedNew;
  bool touchedConfirm;

  ChangePasswordData({
    required this.oldPasswordCtrl,
    required this.newPasswordCtrl,
    required this.confirmPasswordCtrl,
    this.obscureOld = true,
    this.obscureNew = true,
    this.obscureConfirm = true,
    this.isLoading = false,
    this.oldPassError,
    this.newPassError,
    this.confirmPassError,
    this.touchedNew = false,
    this.touchedConfirm = false,
  });
}
