import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/profile/change_email/email_otp/Data/email_otp_data.dart';
import 'package:youbook/features/profile/change_email/email_otp/Logic/email_otp_logic.dart';
import 'package:youbook/features/profile/success_otp_popup/UI/success_otp_ui.dart';

class EmailOtpPageUI extends StatefulWidget {
  const EmailOtpPageUI({super.key});

  @override
  State<EmailOtpPageUI> createState() => _EmailOtpPageUIState();
}

class _EmailOtpPageUIState extends State<EmailOtpPageUI> {
  late final EmailOtpData _data;
  late final EmailOtpLogic _logic;

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
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        toolbarHeight: 45,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "OTP Authentication",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: cs.onPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: cs.onPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "We have sent a 6 digits verification code to your email address.\n"
              "Please enter the OTP code to complete your progress to update your account.\n"
              "Make sure you don’t share your OTP to others.",
              style: TextStyle(fontSize: 14, color: cs.onBackground),
            ),
          ),

          // Main Section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.email,
                    size: 100,
                    color: cs.onPrimary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Enter OTP Code",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (i) => SizedBox(
                        width: 42,
                        child: TextField(
                          controller: _data.otpControllers[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counter: const Offstage(),
                            filled: true,
                            fillColor: cs.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: cs.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: cs.secondary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && i < 5)
                              FocusScope.of(context).nextFocus();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _data.isVerifying
                          ? null
                          : () => _logic.verifyOtp(
                              context,
                              () => setState(() {}),
                              () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const EmailOtpSuccessPopup(),
                                );
                              },
                            ),
                      child: _data.isVerifying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.hintWhite,
                              ),
                            )
                          : const Text(
                              "Verify now",
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Timer
                  if (_data.secondsRemaining > 0) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _data.formattedTime,
                        key: ValueKey(_data.formattedTime),
                        style: TextStyle(fontSize: 16, color: cs.onPrimary),
                      ),
                    ),
                    Text(
                      "Time remaining",
                      style: TextStyle(color: cs.onPrimary),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Resend
                  Column(
                    children: [
                      Text(
                        "Don’t receive OTP?",
                        style: TextStyle(color: cs.onPrimary),
                      ),
                      TextButton(
                        onPressed:
                            (_data.isResending || _data.secondsRemaining > 0)
                            ? null
                            : () => _logic.resendCode(() => setState(() {})),
                        child: _data.isResending
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accentOrange,
                                ),
                              )
                            : Text(
                                "Resend code",
                                style: TextStyle(
                                  color: (_data.secondsRemaining > 0)
                                      ? cs.onPrimary.withOpacity(0.5)
                                      : cs.secondary,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
