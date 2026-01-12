import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/profile/account/account_page/UI/account_page_ui.dart';

class SuccessOtpPopupUI extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onContinue;

  const SuccessOtpPopupUI({
    super.key,
    this.title = "Success!",
    this.message = "Your account has been successfully updated.",
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.successGreen, size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (onContinue != null) {
                  onContinue!();
                } else {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("ok"),
            ),
          ],
        ),
      ),
    );
  }
}

// Specific success popups for different OTP types
class EmailOtpSuccessPopup extends StatelessWidget {
  final VoidCallback? onContinue;

  const EmailOtpSuccessPopup({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) {
    return SuccessOtpPopupUI(
      title: "Email Updated!",
      message: "Your email address has been successfully updated.",
      onContinue: onContinue ?? () {
        // Navigate directly to account page, removing all intermediate screens
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AccountPageUI()),
          (route) => false, // Remove all routes
        );
      },
    );
  }
}

class PhoneOtpSuccessPopup extends StatelessWidget {
  final VoidCallback? onContinue;

  const PhoneOtpSuccessPopup({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) {
    return SuccessOtpPopupUI(
      title: "Phone Number Updated!",
      message: "Your phone number has been successfully updated.",
      onContinue: onContinue ?? () {
        // Navigate directly to account page, removing all intermediate screens
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AccountPageUI()),
          (route) => false, // Remove all routes
        );
      },
    );
  }
}
