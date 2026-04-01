import 'package:youbook/features/support/support_page/UI/help_support_ui.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyLogic {
  void navigateBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const HelpSupportPage(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }
}
