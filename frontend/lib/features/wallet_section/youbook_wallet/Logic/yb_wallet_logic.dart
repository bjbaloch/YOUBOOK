import 'package:flutter/material.dart';
import '../Data/yb_wallet_data.dart';

class WalletLogic {
  final WalletData data = WalletData();

  void selectTab(int index, VoidCallback updateUI) {
    data.selectedTab = index;
    updateUI();
  }

  Future<void> startTopUp(BuildContext context, Future<void> Function() navigateToTopUp, VoidCallback updateUI) async {
    if (data.isLoading) return;

    data.isLoading = true;
    updateUI();

    // Optional UX delay
    await Future.delayed(const Duration(milliseconds: 500));

    await navigateToTopUp();

    data.isLoading = false;
    updateUI();
  }

  // Add a transaction to the wallet
  void addTransaction(String type, double amount, String description) {
    final transaction = {
      'id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'type': type,
      'amount': amount,
      'description': description,
      'date': DateTime.now(),
      'status': 'completed',
    };

    data.addTransaction(transaction);
    data.updateBalance(amount, type == 'credit');
  }

  // Process a top-up
  void processTopUp(double amount) {
    addTransaction('credit', amount, 'Wallet Top-up');
  }

  // Process a payment
  void processPayment(double amount, String description) {
    addTransaction('debit', amount, description);
  }

  // Get formatted balance
  String getFormattedBalance() {
    return 'PKR ${data.balance.toStringAsFixed(2)}';
  }

  // Get transaction count for current tab
  int getTransactionCount() {
    return data.getFilteredItems().length;
  }

  // Check if wallet has sufficient balance
  bool hasSufficientBalance(double amount) {
    return data.balance >= amount;
  }
}
