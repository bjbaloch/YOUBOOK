// data.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VanFormData {
  bool isAgreedToTerms = false;
  bool isSeatLayoutConfigured = false;

  String? selectedVanType;

  // Seat Layout Data
  Map<String, dynamic>? seatLayoutData;

  // Van Information
  final TextEditingController vanNameController = TextEditingController();
  final TextEditingController vanNumberController = TextEditingController();
  final TextEditingController vanColorController = TextEditingController();

  // Proprietor Information
  final TextEditingController proprietorController = TextEditingController();
  final TextEditingController generalManagerController =
      TextEditingController();
  final TextEditingController managerController = TextEditingController();
  final TextEditingController secretaryController = TextEditingController();

  // Route Information
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  // Office/Terminal Information
  final TextEditingController boardingOfficeController =
      TextEditingController();
  final TextEditingController arrivalOfficeController = TextEditingController();

  // Schedule Details
  final TextEditingController departureController = TextEditingController();
  final TextEditingController arrivalController = TextEditingController();

  // Seat & Pricing Details
  final TextEditingController priceController = TextEditingController();
  final TextEditingController applicationController = TextEditingController();

  void dispose() {
    vanNameController.dispose();
    vanNumberController.dispose();
    vanColorController.dispose();
    proprietorController.dispose();
    generalManagerController.dispose();
    managerController.dispose();
    secretaryController.dispose();
    fromController.dispose();
    toController.dispose();
    boardingOfficeController.dispose();
    arrivalOfficeController.dispose();
    departureController.dispose();
    arrivalController.dispose();
    priceController.dispose();
    applicationController.dispose();
  }

  void setSeatLayoutData(Map<String, dynamic> layoutData) {
    seatLayoutData = layoutData;
    isSeatLayoutConfigured = true;
  }

  Map<String, dynamic> toJson() {
    return {
      'vanName': vanNameController.text.trim(),
      'vanNumber': vanNumberController.text.trim(),
      'vanColor': vanColorController.text.trim(),
      'proprietor': proprietorController.text.trim(),
      'generalManager': generalManagerController.text.trim(),
      'manager': managerController.text.trim(),
      'secretary': secretaryController.text.trim(),
      'from': fromController.text.trim(),
      'to': toController.text.trim(),
      'boardingOffice': boardingOfficeController.text.trim(),
      'arrivalOffice': arrivalOfficeController.text.trim(),
      'departureTime': departureController.text.trim(),
      'arrivalTime': arrivalController.text.trim(),
      'pricePerSeat': priceController.text.trim(),
      'applicationCharges': applicationController.text.trim(),
      'isSeatLayoutConfigured': isSeatLayoutConfigured,
      'seatLayoutData': seatLayoutData,
      'type': 'transport',
    };
  }
}

// Custom CNIC Input Formatter
class CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 4 || i == 11) && i != text.length - 1) {
        buffer.write('-');
      }
    }
    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
