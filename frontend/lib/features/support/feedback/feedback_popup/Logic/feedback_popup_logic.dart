import 'package:flutter/material.dart';

class FeedbackLogic {
  void handleSubmit({
    required BuildContext context,
    required TextEditingController controller,
    required void Function(VoidCallback fn) setState,
    required void Function() showSuccessPopup,
    required void Function(String?) setErrorText,
    required void Function(bool) setLoading,
  }) {
    if (controller.text.trim().isEmpty) {
      setErrorText("Feedback cannot be empty");
      return;
    }

    setLoading(true);
    setErrorText(null);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close feedback popup
      Future.microtask(showSuccessPopup);
    });
  }
}
