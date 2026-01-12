// data.dart
import 'package:flutter/material.dart';

class VanFormData {
  bool isAgreedToTerms = false;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController applicationController = TextEditingController();
  final TextEditingController departureController = TextEditingController();
  final TextEditingController arrivalController = TextEditingController();

  String? selectedVanType;

  void dispose() {
    priceController.dispose();
    applicationController.dispose();
    departureController.dispose();
    arrivalController.dispose();
  }
}
