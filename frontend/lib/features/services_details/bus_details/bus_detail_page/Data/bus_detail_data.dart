// data.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BusFormData {
  bool isAgreedToTerms = false;
  bool isSeatLayoutConfigured = false;
  String? selectedBusType;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController applicationController = TextEditingController();
  final TextEditingController departureController = TextEditingController();
  final TextEditingController arrivalController = TextEditingController();

  void dispose() {
    priceController.dispose();
    applicationController.dispose();
    departureController.dispose();
    arrivalController.dispose();
  }
}

// Custom CNIC Input Formatter
class CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('-', '');
    String newText = '';

    if (text.length > 5) {
      newText += text.substring(0, 5) + '-';
      if (text.length > 12) {
        newText += text.substring(5, 12) + '-';
        newText += text.substring(12);
      } else {
        newText += text.substring(5);
      }
    } else {
      newText = text;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
