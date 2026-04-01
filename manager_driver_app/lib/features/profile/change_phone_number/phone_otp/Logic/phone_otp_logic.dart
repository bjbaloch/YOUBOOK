import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manager_driver_app/core/widgets/success_dialog.dart';
import 'package:manager_driver_app/features/profile/change_phone_number/phone_otp/Data/phone_otp_data.dart';
import 'package:manager_driver_app/features/profile/account/account_page/UI/account_page_ui.dart';

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
    debugPrint('Entered OTP (Phone): $otp');

    data.isVerifying = true;
    updateUI();

    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      data.isVerifying = false;
      updateUI();

      SuccessDialog.show(
        context,
        title: 'Phone Number Updated!',
        message: 'Your phone number has been successfully updated.',
        icon: Icons.phone_rounded,
        buttonLabel: 'Done',
        onDone: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AccountPageUI()),
          (route) => false,
        ),
      );
    });
  }

  void resendCode() {
    data.isResending = true;
    updateUI();

    Future.delayed(const Duration(seconds: 2), () {
      data.isResending = false;
      startCountdown();
      debugPrint('OTP code resent to phone');
    });
  }

  void dispose() {
    _timer?.cancel();
    data.dispose();
  }
}
