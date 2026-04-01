import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manager_driver_app/features/profile/change_phone_number/change_pn_page/Data/change_pn_data.dart';


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

  void onVerify(BuildContext context, VoidCallback onUpdate, VoidCallback onSuccess) {
    if (data.phoneError != null || data.phone.isEmpty) return;

    data.isLoading = true;
    onUpdate();

    Future.delayed(const Duration(seconds: 2), () {
      data.isLoading = false;
      onUpdate();
      if (!context.mounted) return;
      onSuccess();
    });
  }
}
