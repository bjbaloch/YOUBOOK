// data.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BusFormData {
  bool isAgreedToTerms = false;
  bool isSeatLayoutConfigured = false;
  String? selectedBusType;

  // Seat Layout Data
  Map<String, dynamic>? seatLayoutData;

  // Bus Information
  final TextEditingController busNameController = TextEditingController();
  final TextEditingController busNumberController = TextEditingController();
  final TextEditingController busColorController = TextEditingController();

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
    busNameController.dispose();
    busNumberController.dispose();
    busColorController.dispose();
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
      'busName': busNameController.text.trim(),
      'busNumber': busNumberController.text.trim(),
      'busColor': busColorController.text.trim(),
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
