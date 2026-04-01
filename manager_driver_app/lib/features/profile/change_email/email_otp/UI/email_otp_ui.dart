import 'package:flutter/material.dart';
import 'package:manager_driver_app/core/widgets/success_dialog.dart';
import 'package:manager_driver_app/features/profile/change_email/email_otp/Data/email_otp_data.dart';
import 'package:manager_driver_app/features/profile/change_email/email_otp/Logic/email_otp_logic.dart';
import 'package:manager_driver_app/features/profile/account/account_page/UI/account_page_ui.dart';
import 'package:manager_driver_app/features/profile/success_otp_popup/UI/otp_page_shell.dart';

class EmailOtpPageUI extends StatefulWidget {
  const EmailOtpPageUI({super.key});

  @override
  State<EmailOtpPageUI> createState() => _EmailOtpPageUIState();
}

class _EmailOtpPageUIState extends State<EmailOtpPageUI> {
  late final EmailOtpData _data;
  late final EmailOtpLogic _logic;
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _data = EmailOtpData(
      otpControllers: List.generate(6, (_) => TextEditingController()),
    );
    _logic = EmailOtpLogic(data: _data);
    _logic.startCountdown(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final fn in _focusNodes) fn.dispose();
    _logic.dispose();
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
      _data.otpControllers.every((c) => c.text.isNotEmpty);

  void _onVerify() {
    _logic.verifyOtp(
      context,
      () => setState(() {}),
      () => SuccessDialog.show(
        context,
        title: 'Email Updated!',
        message: 'Your email address has been successfully updated.',
        icon: Icons.email_rounded,
        buttonLabel: 'Done',
        onDone: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AccountPageUI()),
          (route) => false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OtpPageShell(
      icon: Icons.email_rounded,
      title: 'Email Verification',
      subtitle: 'We sent a 6-digit code to your\nemail address',
      secondsRemaining: _data.secondsRemaining,
      isVerifying: _data.isVerifying,
      isResending: _data.isResending,
      isOtpComplete: _isOtpComplete,
      otpControllers: _data.otpControllers,
      focusNodes: _focusNodes,
      onOtpChanged: _onOtpChanged,
      onVerify: _onVerify,
      onResend: () => _logic.resendCode(() => setState(() {})),
    );
  }
}
