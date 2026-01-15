import '../../../../core/services/api_service.dart';

class WalletData {
  double balance;
  int selectedTab; // 0 = Transactions, 1 = Pending
  bool isLoading;
  List<Map<String, dynamic>> transactions;
  List<Map<String, dynamic>> pending;
  final ApiService _apiService = ApiService();

  WalletData({
    this.balance = 0.0, // Start with zero balance
    this.selectedTab = 0,
    this.isLoading = false,
    List<Map<String, dynamic>>? transactions,
    List<Map<String, dynamic>>? pending,
  }) :
        transactions = transactions ?? [],
        pending = pending ?? [];

  Future<void> loadWalletData() async {
    isLoading = true;
    try {
      final walletData = await _apiService.getPassengerWallet();
      balance = (walletData['balance'] ?? 0.0).toDouble();
    } catch (e) {
      balance = 0.0;
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Future<void> loadTransactions() async {
    try {
      final transactionsData = await _apiService.getPassengerTransactions();
      transactions = List<Map<String, dynamic>>.from(transactionsData);
    } catch (e) {
      transactions = [];
      rethrow;
    }
  }

  Future<void> loadPendingTransactions() async {
    try {
      final pendingData = await _apiService.getPassengerPendingTransactions();
      pending = List<Map<String, dynamic>>.from(pendingData);
    } catch (e) {
      pending = [];
      rethrow;
    }
  }

  // Get filtered transactions based on selected tab
  List<Map<String, dynamic>> getFilteredItems() {
    return selectedTab == 0 ? transactions : pending;
  }

  // Add a new transaction
  void addTransaction(Map<String, dynamic> transaction) {
    transactions.insert(0, transaction);
  }

  // Update balance
  void updateBalance(double amount, bool isCredit) {
    if (isCredit) {
      balance += amount;
    } else {
      balance -= amount;
    }
  }

  // Get total spent this month
  double getMonthlySpent() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return transactions
        .where((txn) =>
            txn['type'] == 'debit' &&
            (txn['date'] as DateTime).isAfter(startOfMonth))
        .fold(0.0, (sum, txn) => sum + (txn['amount'] as double));
  }

  // Get total top-ups this month
  double getMonthlyTopUps() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return transactions
        .where((txn) =>
            txn['type'] == 'credit' &&
            txn['description'].toString().contains('Top-up') &&
            (txn['date'] as DateTime).isAfter(startOfMonth))
        .fold(0.0, (sum, txn) => sum + (txn['amount'] as double));
  }
}
