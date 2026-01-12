import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youbook/features/profile/change_email/email_otp/Data/email_otp_data.dart';

class EmailOtpLogic {
  final EmailOtpData data;
  Timer? _timer;

  EmailOtpLogic({required this.data});

  void startCountdown(VoidCallback updateUI) {
    _timer?.cancel();
    data.secondsRemaining = 60;
    updateUI();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (data.secondsRemaining > 0) {
        data.secondsRemaining--;
        updateUI();
      } else {
        timer.cancel();
      }
    });
  }

  void verifyOtp(
    BuildContext context,
    VoidCallback updateUI,
    VoidCallback onSuccess,
  ) {
    final otp = data.otpCode;
    debugPrint("Entered OTP: $otp");

    data.isVerifying = true;
    updateUI();

    // Fake delay for verification
    Future.delayed(const Duration(seconds: 2), () {
      data.isVerifying = false;
      updateUI();

      if (!context.mounted) return;
      onSuccess();
    });
  }

  void resendCode(VoidCallback updateUI) {
    data.isResending = true;
    updateUI();

    Future.delayed(const Duration(seconds: 2), () {
      data.isResending = false;
      data.secondsRemaining = 60;
      updateUI();
      debugPrint("OTP code resent to email");
    });
  }

  void dispose() {
    _timer?.cancel();
    for (var ctrl in data.otpControllers) {
      ctrl.dispose();
    }
  }
}
