// logic.dart
import 'package:flutter/material.dart';

class VanFormLogic {
  void updateApplicationCharges(
    TextEditingController priceController,
    TextEditingController applicationController,
  ) {
    final text = priceController.text.trim();
    if (text.isEmpty) {
      applicationController.text = '';
      return;
    }
    final price = double.tryParse(text);
    if (price != null) {
      final charges = price * 0.03;
      applicationController.text = charges.toStringAsFixed(2);
    } else {
      applicationController.text = '';
    }
  }

  Future<void> pickDateTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 10));

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null) return;

    await Future.delayed(const Duration(milliseconds: 150));

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    controller.text = '${dateTime.toLocal()}'.split('.')[0];
  }
}
