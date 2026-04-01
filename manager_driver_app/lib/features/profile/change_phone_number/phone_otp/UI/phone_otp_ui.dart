import 'package:flutter/material.dart';
import 'package:manager_driver_app/features/profile/change_phone_number/phone_otp/Data/phone_otp_data.dart';
import 'package:manager_driver_app/features/profile/change_phone_number/phone_otp/Logic/phone_otp_logic.dart';
import 'package:manager_driver_app/features/profile/success_otp_popup/UI/otp_page_shell.dart';


class PhoneOtpPageUI extends StatefulWidget {
  const PhoneOtpPageUI({super.key});

  @override
  State<PhoneOtpPageUI> createState() => _PhoneOtpPageUIState();
}

class _PhoneOtpPageUIState extends State<PhoneOtpPageUI> {
  late final PhoneOtpData data;
  late final PhoneOtpLogic logic;
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    data = PhoneOtpData();
    logic = PhoneOtpLogic(data: data, updateUI: () => setState(() {}));
    logic.startCountdown();
  }

  @override
  void dispose() {
    for (final fn in _focusNodes) fn.dispose();
    logic.dispose();
    super.dispose();
  }

  void _onOtpChanged(String val, int index) {
    if (val.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (val.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  bool get _isOtpComplete =>
      data.otpControllers.every((c) => c.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return OtpPageShell(
      icon: Icons.phone_rounded,
      title: 'Phone Verification',
      subtitle: 'We sent a 6-digit code to your\nphone number',
      secondsRemaining: data.secondsRemaining,
      isVerifying: data.isVerifying,
      isResending: data.isResending,
      isOtpComplete: _isOtpComplete,
      otpControllers: data.otpControllers,
      focusNodes: _focusNodes,
      onOtpChanged: _onOtpChanged,
      onVerify: () => logic.verifyOtp(context),
      onResend: logic.resendCode,
    );
  }
}
