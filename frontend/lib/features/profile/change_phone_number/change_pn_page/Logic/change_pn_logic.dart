import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youbook/features/profile/change_phone_number/change_pn_page/Data/change_pn_data.dart';
import 'package:youbook/features/profile/change_phone_number/phone_otp/UI/phone_otp_ui.dart';

class ChangePhoneLogic {
  final ChangePhoneData data;

  ChangePhoneLogic({required this.data});

  void validatePhone(String input, VoidCallback onUpdate) {
    input = input.trim();
    data.phone = input;

    if (input.isEmpty) {
      data.phoneError = "Phone number is required";
    } else if (!input.startsWith("03")) {
      data.phoneError = "Must start with 03";
    } else if (input.length < 11) {
      data.phoneError = "Must be at least 11 digits";
    } else if (input.length > 11) {
      data.phoneError = "Must not exceed 11 digits";
    } else {
      data.phoneError = null;
    }

    onUpdate();
  }

  void onVerify(BuildContext context, VoidCallback onUpdate) {
    if (data.phoneError != null || data.phone.isEmpty) return;

    data.isLoading = true;
    onUpdate();

    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      data.isLoading = false;
      onUpdate();

      Navigator.pop(context); // Close dialog
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PhoneOtpPageUI()),
      );
    });
  }
}
