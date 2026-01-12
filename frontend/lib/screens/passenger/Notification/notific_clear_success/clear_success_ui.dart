import 'package:flutter/material.dart';
import '../../../../core/widgets/confirmation_dialog.dart';

void showSuccessDialogUI(BuildContext context, dynamic data) {
  ConfirmationDialog.show(
    context: context,
    title: 'Success!',
    message: 'All notifications have been cleared successfully.',
    confirmText: 'OK',
    cancelText: '', // Empty string to hide cancel button
    icon: Icons.check_circle_rounded,
    iconColor: Colors.green,
    confirmButtonColor: Colors.green,
    onConfirm: () {
      // Dialog already pops itself, no need to pop again
    },
  );
}
