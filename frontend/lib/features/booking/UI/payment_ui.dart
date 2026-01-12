import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../Data/seat_selection_data.dart';
import '../../../core/models/booking.dart';

class PaymentUI extends StatefulWidget {
  final SeatSelectionData seatData;
  final double totalAmount;
  final String routeName;
  final DateTime travelDate;
  final String departureTime;

  const PaymentUI({
    super.key,
    required this.seatData,
    required this.totalAmount,
    required this.routeName,
    required this.travelDate,
    required this.departureTime,
  });

  @override
  State<PaymentUI> createState() => _PaymentUIState();
}

class _PaymentUIState extends State<PaymentUI> {
  String _selectedPaymentMethod = 'wallet';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'wallet',
      'name': 'YouBook Wallet',
      'icon': Icons.account_balance_wallet,
      'description': 'Pay using your wallet balance',
      'balance': 2500.0,
    },
    {
      'id': 'easypaisa',
      'name': 'EasyPaisa',
      'icon': Icons.phone_android,
      'description': 'Mobile wallet payment',
      'logo': 'assets/topup_accounts/easypaisa.png',
    },
    {
      'id': 'jazzcash',
      'name': 'JazzCash',
      'icon': Icons.phone_android,
      'description': 'Mobile banking payment',
      'logo': 'assets/topup_accounts/jazzcash_logo.png',
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'description': 'Visa, MasterCard, etc.',
      'logo': 'assets/topup_accounts/visa_card.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () => _handleBackPress(context),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: cs.primary,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            title: Text(
              "Payment",
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () => _handleBackPress(context),
            ),
          ),
        ),
        body: SafeArea(
          child: _isProcessing ? _buildProcessingScreen(cs) : _buildPaymentScreen(cs),
        ),
      ),
    );
  }

  Widget _buildProcessingScreen(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payment,
              color: cs.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Payment...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your payment',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildPaymentScreen(ColorScheme cs) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Summary Card
                _bookingSummaryCard(cs),
                const SizedBox(height: 24),

                // Payment Methods
                Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ..._paymentMethods.map((method) => _paymentMethodCard(method, cs)),
              ],
            ),
          ),
        ),
        _bottomBar(cs),
      ],
    );
  }

  Widget _bookingSummaryCard(ColorScheme cs) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Booking Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _summaryRow('Route', widget.routeName),
            _summaryRow('Date', _formatDate(widget.travelDate)),
            _summaryRow('Time', widget.departureTime),
            _summaryRow('Seats', widget.seatData.selectedSeatNumbers.join(', ')),
            _summaryRow('Vehicle Type', widget.seatData.vehicleType == VehicleType.bus ? 'Bus' : 'Van'),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  'Rs. ${widget.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodCard(Map<String, dynamic> method, ColorScheme cs) {
    final isSelected = _selectedPaymentMethod == method['id'];
    final hasBalance = method['balance'] != null;
    final balance = method['balance'] ?? 0.0;
    final hasEnoughBalance = hasBalance && balance >= widget.totalAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? cs.primary : cs.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedPaymentMethod = method['id']),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: method['logo'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        method['logo'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                          Icon(method['icon'], color: cs.primary, size: 20),
                      ),
                    )
                  : Icon(method['icon'], color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      method['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                    ),
                    if (hasBalance) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Balance: Rs. ${balance.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasEnoughBalance ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Radio<String>(
                value: method['id'],
                groupValue: _selectedPaymentMethod,
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                activeColor: cs.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomBar(ColorScheme cs) {
    final selectedMethod = _paymentMethods.firstWhere(
      (method) => method['id'] == _selectedPaymentMethod,
    );
    final hasBalance = selectedMethod['balance'] != null;
    final balance = selectedMethod['balance'] ?? 0.0;
    final hasEnoughBalance = !hasBalance || balance >= widget.totalAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline.withOpacity(0.3))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Payment',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Rs. ${widget.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: hasEnoughBalance ? _processPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasEnoughBalance ? cs.primary : Colors.grey,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                hasEnoughBalance ? 'Pay Now' : 'Insufficient Balance',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isProcessing = false);
      _showPaymentSuccess();
    }
  }

  void _showPaymentSuccess() {
    // TODO: Navigate to booking receipt
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! (Receipt screen to be implemented)'),
        backgroundColor: Colors.green,
      ),
    );

    // For now, pop back to home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<bool> _handleBackPress(BuildContext context) async {
    if (_isProcessing) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to cancel the payment? Your booking will not be confirmed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Payment'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
