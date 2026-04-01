import 'package:flutter/material.dart';

class TopupData {
  String selectedPaymentMethod;
  TextEditingController amountController;
  double topupAmount;
  String? amountError;

  TopupData({
    this.selectedPaymentMethod = '',
    TextEditingController? amountController,
    this.topupAmount = 0.0,
    this.amountError,
  }) : amountController = amountController ?? TextEditingController();

  // Dispose method to clean up controller
  void dispose() {
    amountController.dispose();
  }

  // Reset selection
  void resetSelection() {
    selectedPaymentMethod = '';
    amountError = null;
  }

  // Validate amount
  bool isAmountValid() {
    if (amountController.text.isEmpty) {
      amountError = "The amount is required to proceed";
      return false;
    }

    topupAmount = double.tryParse(amountController.text) ?? 0.0;
    if (topupAmount < 40 || topupAmount > 10000) {
      amountError = "The amount must be between Rs. 40 and Rs. 10,000";
      return false;
    }

    amountError = null;
    return true;
  }

  // Check if a payment method is selected
  bool isPaymentMethodSelected(String method) {
    return selectedPaymentMethod == method;
  }
}
