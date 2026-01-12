import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
part 'manager_wallet_data.dart';
part 'manager_wallet_ui.dart';

class ManagerWalletScreen extends StatefulWidget {
  const ManagerWalletScreen({super.key});

  @override
  State<ManagerWalletScreen> createState() => _ManagerWalletScreenState();
}

class _ManagerWalletScreenState extends State<ManagerWalletScreen>
    with TickerProviderStateMixin {
  late ManagerWalletData _data;
  late AnimationController _balanceAnimationController;
  late Animation<double> _balanceAnimation;

  @override
  void initState() {
    super.initState();
    _data = ManagerWalletData();
    _initializeWallet();

    // Balance animation
    _balanceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _balanceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _balanceAnimationController,
      curve: Curves.elasticOut,
    ));

    // Start animation after data loads
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _balanceAnimationController.forward();
      }
    });
  }

  Future<void> _initializeWallet() async {
    await _data.loadWalletData();
    await _data.loadTransactions();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _addFunds(double amount) async {
    setState(() {
      _data.isProcessingPayment = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Add funds to wallet
      _data.balance += amount;

      // Add transaction record
      _data.addTransaction(Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.deposit,
        amount: amount,
        description: 'Funds Added',
        timestamp: DateTime.now(),
        status: TransactionStatus.completed,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully added PKR ${amount.toStringAsFixed(0)} to wallet'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add funds: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _data.isProcessingPayment = false;
        });
      }
    }
  }

  Future<void> _withdrawFunds(double amount) async {
    if (_data.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _data.isProcessingPayment = true;
    });

    try {
      // Simulate withdrawal processing
      await Future.delayed(const Duration(seconds: 2));

      // Deduct from wallet
      _data.balance -= amount;

      // Add transaction record
      _data.addTransaction(Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.withdrawal,
        amount: amount,
        description: 'Funds Withdrawn',
        timestamp: DateTime.now(),
        status: TransactionStatus.completed,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully withdrawn PKR ${amount.toStringAsFixed(0)} from wallet'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to withdraw funds: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _data.isProcessingPayment = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _balanceAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Wallet'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _buildWalletUI(this),
    );
  }
}
