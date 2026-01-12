import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';

class SuccessPopupUI extends StatelessWidget {
  final VoidCallback? onContinue;

  const SuccessPopupUI({super.key, this.onContinue});

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
              "Password Updated!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your password has been successfully updated.",
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
                  Navigator.of(context).pop(); // Go back to account page
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
