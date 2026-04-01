import 'package:flutter/material.dart';
import 'package:manager_driver_app/core/widgets/success_dialog.dart';
import 'package:manager_driver_app/features/profile/account/account_page/UI/account_page_ui.dart';

// Kept for backward compatibility — delegates to the shared SuccessDialog.

class EmailOtpSuccessPopup extends StatelessWidget {
  final VoidCallback? onContinue;
  const EmailOtpSuccessPopup({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) {
    // Show via SuccessDialog on first frame then close this widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop(); // close this dialog shell
      SuccessDialog.show(
        context,
        title: 'Email Updated!',
        message: 'Your email address has been successfully updated.',
        icon: Icons.email_rounded,
        buttonLabel: 'Done',
        onDone: onContinue ??
            () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AccountPageUI()),
                  (route) => false,
                ),
      );
    });
    return const SizedBox.shrink();
  }
}

class PhoneOtpSuccessPopup extends StatelessWidget {
  final VoidCallback? onContinue;
  const PhoneOtpSuccessPopup({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      SuccessDialog.show(
        context,
        title: 'Phone Number Updated!',
        message: 'Your phone number has been successfully updated.',
        icon: Icons.phone_rounded,
        buttonLabel: 'Done',
        onDone: onContinue ??
            () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AccountPageUI()),
                  (route) => false,
                ),
      );
    });
    return const SizedBox.shrink();
  }
}
