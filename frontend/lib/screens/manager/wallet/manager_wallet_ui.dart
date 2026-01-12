part of 'manager_wallet_screen.dart';

Widget _buildWalletUI(_ManagerWalletScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  return RefreshIndicator(
    onRefresh: () async {
      await state._initializeWallet();
    },
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          _buildBalanceCard(state),

          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(state),

          const SizedBox(height: 24),

          // Wallet Stats
          if (state._data.stats != null) _buildWalletStats(state),

          const SizedBox(height: 24),

          // Transaction History
          _buildTransactionHistory(state),
        ],
      ),
    ),
  );
}

Widget _buildBalanceCard(_ManagerWalletScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  return AnimatedBuilder(
    animation: state._balanceAnimation,
    builder: (context, child) {
      return Transform.scale(
        scale: state._balanceAnimation.value,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: cs.onPrimary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Current Balance',
                      style: TextStyle(
                        color: cs.onPrimary.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'PKR ${state._data.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Available for transactions',
                  style: TextStyle(
                    color: cs.onPrimary.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildQuickActions(_ManagerWalletScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quick Actions',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.add_circle,
              label: 'Add Funds',
              color: Colors.green,
              onPressed: () => _showAddFundsDialog(state),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.remove_circle,
              label: 'Withdraw',
              color: Colors.orange,
              onPressed: () => _showWithdrawDialog(state),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.receipt_long,
              label: 'View All',
              color: cs.primary,
              onPressed: () => _showAllTransactions(state),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.analytics,
              label: 'Analytics',
              color: Colors.purple,
              onPressed: () => _showAnalytics(state),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildActionButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color.withOpacity(0.1),
      foregroundColor: color,
      elevation: 2,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildWalletStats(_ManagerWalletScreenState state) {
  final cs = Theme.of(state.context).colorScheme;
  final stats = state._data.stats!;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Wallet Statistics',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildStatCard(
              state.context,
              title: 'Total Revenue',
              value: 'PKR ${stats.totalRevenue.toStringAsFixed(0)}',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              state.context,
              title: 'Total Expenses',
              value: 'PKR ${stats.totalExpenses.toStringAsFixed(0)}',
              icon: Icons.trending_down,
              color: Colors.red,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildStatCard(
              state.context,
              title: 'Transactions',
              value: '${stats.totalTransactions}',
              icon: Icons.swap_horiz,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              state.context,
              title: 'Avg Transaction',
              value: 'PKR ${stats.averageTransaction.toStringAsFixed(0)}',
              icon: Icons.calculate,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildStatCard(
  BuildContext context, {
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  final cs = Theme.of(context).colorScheme;

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildTransactionHistory(_ManagerWalletScreenState state) {
  final cs = Theme.of(state.context).colorScheme;
  final recentTransactions = state._data.getRecentTransactions(limit: 5);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          TextButton(
            onPressed: () => _showAllTransactions(state),
            child: Text(
              'View All',
              style: TextStyle(color: cs.primary),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (recentTransactions.isEmpty)
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: cs.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        )
      else
        ...recentTransactions.map((transaction) => _buildTransactionItem(state.context, transaction)),
    ],
  );
}

Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
  final cs = Theme.of(context).colorScheme;

  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTransactionColor(transaction.type).withOpacity(0.1),
        child: Icon(
          _getTransactionIcon(transaction.type),
          color: _getTransactionColor(transaction.type),
        ),
      ),
      title: Text(
        transaction.description,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
      ),
      subtitle: Text(
        _formatDate(transaction.timestamp),
        style: TextStyle(
          color: cs.onSurface.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${_getTransactionSign(transaction.type)}PKR ${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getTransactionColor(transaction.type),
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(transaction.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              transaction.status.toString().split('.').last.toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(transaction.status),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper functions
void _showAddFundsDialog(_ManagerWalletScreenState state) {
  showDialog(
    context: state.context,
    builder: (context) => _AddFundsDialog(
      onAddFunds: (amount) {
        Navigator.of(context).pop();
        state._addFunds(amount);
      },
    ),
  );
}

void _showWithdrawDialog(_ManagerWalletScreenState state) {
  showDialog(
    context: state.context,
    builder: (context) => _WithdrawDialog(
      currentBalance: state._data.balance,
      onWithdraw: (amount) {
        Navigator.of(context).pop();
        state._withdrawFunds(amount);
      },
    ),
  );
}

void _showAllTransactions(_ManagerWalletScreenState state) {
  Navigator.of(state.context).push(
    MaterialPageRoute(
      builder: (_) => _TransactionHistoryScreen(
        transactions: state._data.transactions,
      ),
    ),
  );
}

void _showAnalytics(_ManagerWalletScreenState state) {
  Navigator.of(state.context).push(
    MaterialPageRoute(
      builder: (_) => _WalletAnalyticsScreen(
        stats: state._data.stats,
        transactions: state._data.transactions,
      ),
    ),
  );
}

// Helper functions
String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  } else if (difference.inDays == 1) {
    return 'Yesterday ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

String _getTransactionSign(TransactionType type) {
  switch (type) {
    case TransactionType.deposit:
    case TransactionType.refund:
      return '+';
    case TransactionType.withdrawal:
    case TransactionType.payment:
    case TransactionType.service_fee:
      return '-';
  }
}

Color _getTransactionColor(TransactionType type) {
  switch (type) {
    case TransactionType.deposit:
    case TransactionType.refund:
      return Colors.green;
    case TransactionType.withdrawal:
      return Colors.orange;
    case TransactionType.payment:
    case TransactionType.service_fee:
      return Colors.red;
  }
}

IconData _getTransactionIcon(TransactionType type) {
  switch (type) {
    case TransactionType.deposit:
      return Icons.arrow_downward;
    case TransactionType.withdrawal:
      return Icons.arrow_upward;
    case TransactionType.payment:
    case TransactionType.service_fee:
      return Icons.payment;
    case TransactionType.refund:
      return Icons.refresh;
  }
}

Color _getStatusColor(TransactionStatus status) {
  switch (status) {
    case TransactionStatus.completed:
      return Colors.green;
    case TransactionStatus.pending:
      return Colors.orange;
    case TransactionStatus.failed:
      return Colors.red;
    case TransactionStatus.cancelled:
      return Colors.grey;
  }
}

// Dialog widgets
class _AddFundsDialog extends StatefulWidget {
  final Function(double) onAddFunds;

  const _AddFundsDialog({required this.onAddFunds});

  @override
  State<_AddFundsDialog> createState() => _AddFundsDialogState();
}

class _AddFundsDialogState extends State<_AddFundsDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Add Funds'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (PKR)',
            hintText: 'Enter amount',
            prefixText: 'PKR ',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount > 100000) {
              return 'Maximum amount is PKR 100,000';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: cs.onSurface)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_controller.text);
              widget.onAddFunds(amount);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Funds'),
        ),
      ],
    );
  }
}

class _WithdrawDialog extends StatefulWidget {
  final double currentBalance;
  final Function(double) onWithdraw;

  const _WithdrawDialog({
    required this.currentBalance,
    required this.onWithdraw,
  });

  @override
  State<_WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<_WithdrawDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Withdraw Funds'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Balance: PKR ${widget.currentBalance.toStringAsFixed(2)}',
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (PKR)',
                hintText: 'Enter amount to withdraw',
                prefixText: 'PKR ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount > widget.currentBalance) {
                  return 'Insufficient balance';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: cs.onSurface)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_controller.text);
              widget.onWithdraw(amount);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Withdraw'),
        ),
      ],
    );
  }
}

// Additional screens
class _TransactionHistoryScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const _TransactionHistoryScreen({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: cs.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: TextStyle(
                      fontSize: 18,
                      color: cs.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionItem(context, transactions[index]);
              },
            ),
    );
  }
}

class _WalletAnalyticsScreen extends StatelessWidget {
  final WalletStats? stats;
  final List<Transaction> transactions;

  const _WalletAnalyticsScreen({
    required this.stats,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Analytics'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: stats == null
          ? const Center(child: Text('No data available'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Summary',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalyticsCard(
                          context,
                          title: 'Net Balance',
                          value: 'PKR ${(stats!.totalRevenue - stats!.totalExpenses).toStringAsFixed(0)}',
                          icon: Icons.account_balance,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalyticsCard(
                          context,
                          title: 'Revenue',
                          value: 'PKR ${stats!.totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildAnalyticsCard(
                          context,
                          title: 'Expenses',
                          value: 'PKR ${stats!.totalExpenses.toStringAsFixed(0)}',
                          icon: Icons.trending_down,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Transaction Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionBreakdown(context),
                ],
              ),
            ),
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionBreakdown(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final typeBreakdown = <TransactionType, int>{};

    for (final transaction in transactions) {
      typeBreakdown[transaction.type] = (typeBreakdown[transaction.type] ?? 0) + 1;
    }

    return Column(
      children: TransactionType.values.map((type) {
        final count = typeBreakdown[type] ?? 0;
        final percentage = transactions.isEmpty ? 0.0 : (count / transactions.length) * 100;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTransactionColor(type).withOpacity(0.1),
              child: Icon(
                _getTransactionIcon(type),
                color: _getTransactionColor(type),
              ),
            ),
            title: Text(type.toString().split('.').last),
            trailing: Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
