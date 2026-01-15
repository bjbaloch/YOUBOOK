part of 'manager_wallet_screen.dart';

enum TransactionType {
  deposit,
  withdrawal,
  payment,
  refund,
  service_fee,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime timestamp;
  final TransactionStatus status;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TransactionType.payment,
      ),
      amount: json['amount']?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
    );
  }
}

class WalletStats {
  final double totalRevenue;
  final double totalExpenses;
  final int totalTransactions;
  final double averageTransaction;

  WalletStats({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalTransactions,
    required this.averageTransaction,
  });
}

class ManagerWalletData {
  double balance = 0.0;
  List<Transaction> transactions = [];
  WalletStats? stats;
  bool isProcessingPayment = false;
  final ApiService _apiService = ApiService();

  Future<void> loadWalletData() async {
    try {
      final walletData = await _apiService.getManagerWallet();
      balance = (walletData['balance'] ?? 0.0).toDouble();
    } catch (e) {
      balance = 0.0;
      rethrow;
    } finally {
      _calculateStats();
    }
  }

  Future<void> loadTransactions() async {
    try {
      final transactionsData = await _apiService.getManagerTransactions();
      transactions = transactionsData.map((json) => Transaction.fromJson(json)).toList();
      // Sort by timestamp (newest first)
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      transactions = [];
      rethrow;
    } finally {
      _calculateStats();
    }
  }

  void addTransaction(Transaction transaction) {
    transactions.insert(0, transaction);
    _calculateStats();
  }

  void _calculateStats() {
    if (transactions.isEmpty) {
      stats = WalletStats(
        totalRevenue: 0.0,
        totalExpenses: 0.0,
        totalTransactions: 0,
        averageTransaction: 0.0,
      );
      return;
    }

    double revenue = 0.0;
    double expenses = 0.0;

    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.deposit:
        case TransactionType.refund:
          revenue += transaction.amount;
          break;
        case TransactionType.withdrawal:
        case TransactionType.payment:
        case TransactionType.service_fee:
          expenses += transaction.amount;
          break;
      }
    }

    stats = WalletStats(
      totalRevenue: revenue,
      totalExpenses: expenses,
      totalTransactions: transactions.length,
      averageTransaction: transactions.fold<double>(0.0, (sum, t) => sum + t.amount) / transactions.length,
    );
  }

  List<Transaction> getRecentTransactions({int limit = 10}) {
    return transactions.take(limit).toList();
  }

  List<Transaction> getTransactionsByType(TransactionType type) {
    return transactions.where((t) => t.type == type).toList();
  }

  double getTotalByType(TransactionType type) {
    return transactions
        .where((t) => t.type == type)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }
}
