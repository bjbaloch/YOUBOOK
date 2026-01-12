import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youbook/features/profile/change_phone_number/phone_otp/Data/phone_otp_data.dart';
import 'package:youbook/features/profile/success_otp_popup/UI/success_otp_ui.dart';

class PhoneOtpLogic {
  final PhoneOtpData data;
  final VoidCallback updateUI;
  Timer? _timer;

  PhoneOtpLogic({required this.data, required this.updateUI});

  void startCountdown() {
    _timer?.cancel();
    data.secondsRemaining = 60;
    updateUI();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (data.secondsRemaining > 0) {
        data.secondsRemaining--;
        updateUI();
      } else {
        timer.cancel();
        updateUI();
      }
    });
  }

  void verifyOtp(BuildContext context) {
    final otp = data.otpControllers.map((e) => e.text).join();
    debugPrint("Entered OTP (Phone): $otp");

    data.isVerifying = true;
    updateUI();

    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;

      data.isVerifying = false;
      updateUI();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PhoneOtpSuccessPopup(),
      );
    });
  }

  void resendCode() {
    data.isResending = true;
    updateUI();

    Future.delayed(const Duration(seconds: 2), () {
      data.isResending = false;
      startCountdown();
      debugPrint("OTP code resent to phone");
      updateUI();
    });
  }

  void dispose() {
    _timer?.cancel();
    data.dispose();
  }
}
