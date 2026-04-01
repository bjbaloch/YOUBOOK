import 'package:youbook/features/support/support_page/UI/help_support_ui.dart';
import 'package:flutter/material.dart';

class TermsConditionsLogic {
  PageRouteBuilder smoothRouteToHelpSupport() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const HelpSupportPage(),
      transitionsBuilder: (context, anim, secAnim, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
  }

  void handleBackPress(BuildContext context) {
    Navigator.pushReplacement(context, smoothRouteToHelpSupport());
  }
}
