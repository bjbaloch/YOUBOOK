import 'package:flutter/material.dart';

class EmailOtpData {
  final List<TextEditingController> otpControllers;
  int secondsRemaining;
  bool isVerifying;
  bool isResending;

  EmailOtpData({
    required this.otpControllers,
    this.secondsRemaining = 0,
    this.isVerifying = false,
    this.isResending = false,
  });

  String get otpCode => otpControllers.map((e) => e.text).join();

  String get formattedTime {
    if (secondsRemaining <= 0) return "00 : 00";
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes : $seconds";
  }
}
