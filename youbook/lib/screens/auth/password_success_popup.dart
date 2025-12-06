// lib/Success/success_popup.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youbook/screens/auth/login_screen.dart';
import 'package:youbook/core/theme/app_colors.dart';

class SuccessPopup extends StatefulWidget {
  const SuccessPopup({super.key});

  @override
  State<SuccessPopup> createState() => _SuccessPopupState();
}

class _SuccessPopupState extends State<SuccessPopup> {
  bool _canClose = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Must display for at least 3 seconds
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _canClose = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _goToLogin() async {
    if (!_canClose || !mounted) return;
    // Push Login and clear everything (including this dialog)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Match ForgetPasswordPopup sizing (fixed height 350, width up to 500)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 500 ? 500 : screenWidth - 50;
    const double dialogHeight = 300;

    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      // Prevent back key to ensure minimum display time
      onWillPop: () async => false,
      child: Center(
        child: Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              // Keyboard-safe (though not likely needed here)
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 30,
                bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green Circle with check
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.circleGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 70,
                      color: AppColors.textOnCircle,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Success text
                  const Text(
                    "Your password has been changed successfully",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  // Done button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _goToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper to open SuccessPopup:
/// - Closes any other open popups behind it
/// - Uses the root navigator to avoid stacking on existing dialogs
Future<void> showSuccessPopup(BuildContext context) async {
  // Close all PopupRoutes (dialogs, bottom sheets) before showing this one
  Navigator.of(
    context,
    rootNavigator: true,
  ).popUntil((route) => route is PageRoute);

  // Show success popup
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.overlay,
    useRootNavigator: true,
    builder: (_) => const SuccessPopup(),
  );
}
