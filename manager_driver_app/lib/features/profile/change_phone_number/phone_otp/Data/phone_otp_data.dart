import 'package:flutter/material.dart';

class PhoneOtpData {
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  int secondsRemaining = 0;
  bool isVerifying = false;
  bool isResending = false;

  void dispose() {
    for (var ctrl in otpControllers) {
      ctrl.dispose();
    }
  }

  String get formattedTime {
    if (secondsRemaining <= 0) return "00 : 00";
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes : $seconds";
  }
}
