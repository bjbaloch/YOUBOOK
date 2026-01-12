import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../Data/topup_data.dart';

class TopupLogic {
  final TopupData data = TopupData();

  void updateTopupAmount(VoidCallback updateUI) {
    data.topupAmount = double.tryParse(data.amountController.text) ?? 0.0;
    if (data.amountController.text.isNotEmpty) {
      data.amountError = null;
    }
    updateUI();
  }

  void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void handlePaymentTap(
    BuildContext context,
    String method,
    VoidCallback updateUI,
  ) {
    FocusScope.of(context).unfocus();
    data.selectedPaymentMethod = '';

    if (!data.isAmountValid()) {
      updateUI();
      return;
    }

    data.selectedPaymentMethod = method;
    data.amountError = null;
    updateUI();

    // Show processing snackbar first
    showSnackBar(
      context,
      'Processing ${method} payment of Rs. ${data.topupAmount.toStringAsFixed(2)}...',
      isError: false,
    );

    // Simulate payment processing delay
    Future.delayed(const Duration(seconds: 2), () async {
      if (context.mounted) {
        // Show success dialog
        await SuccessDialog.show(
          context,
          title: 'Payment Successful!',
          message:
              'Rs. ${data.topupAmount.toStringAsFixed(2)} has been added to your YouBook Wallet.',
          icon: Icons.account_balance_wallet,
          iconBackgroundColor: AppColors.circleGreen,
        );

        // Navigate back after dialog is dismissed
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    });

    debugPrint('Processing $method payment for amount: ${data.topupAmount}');
  }

  // Get available payment methods
  List<Map<String, dynamic>> getPaymentMethods() {
    return [
      {
        'name': 'Easypaisa',
        'logo': 'assets/topup_accounts/easypaisa.png',
        'description': 'Mobile wallet payment',
      },
      {
        'name': 'JazzCash',
        'logo': 'assets/topup_accounts/jazzcash_logo.png',
        'description': 'Mobile banking payment',
      },
      {
        'name': 'Debit / Visa Card',
        'logo': 'assets/topup_accounts/visa_card.png',
        'description': 'Credit/Debit card payment',
      },
    ];
  }

  // Validate and format amount
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an amount";
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return "Please enter a valid amount";
    }

    if (amount < 40) {
      return "Minimum amount is Rs. 40";
    }

    if (amount > 10000) {
      return "Maximum amount is Rs. 10,000";
    }

    return null;
  }

  // Format amount for display
  String formatAmount(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }
}
