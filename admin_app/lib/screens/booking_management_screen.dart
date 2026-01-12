import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  final List<String> _statuses = ['all', 'confirmed', 'cancelled', 'completed', 'refunded'];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      final apiService = authProvider.getApiService();

      // Mock booking data - replace with actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

      setState(() {
        _bookings = [
          {
            'id': 'bk_001',
            'passengerName': 'Ali Khan',
            'passengerEmail': 'ali@example.com',
            'route': 'Lahore → Islamabad',
            'vehicle': 'LHR-1234',
            'seats': ['A1', 'A2'],
            'bookingDate': '2024-01-15 10:30',
            'travelDate': '2024-01-16 08:00',
            'status': 'confirmed',
            'totalAmount': 2400,
            'paymentStatus': 'paid',
          },
          {
            'id': 'bk_002',
            'passengerName': 'Sara Ahmed',
            'passengerEmail': 'sara@example.com',
            'route': 'Karachi → Lahore',
            'vehicle': 'KHI-5678',
            'seats': ['B3'],
            'bookingDate': '2024-01-14 14:20',
            'travelDate': '2024-01-15 22:00',
            'status': 'cancelled',
            'totalAmount': 3500,
            'paymentStatus': 'refunded',
          },
          {
            'id': 'bk_003',
            'passengerName': 'Usman Raza',
            'passengerEmail': 'usman@example.com',
            'route': 'Islamabad → Peshawar',
            'vehicle': 'ISB-9012',
            'seats': ['C1', 'C2', 'C3'],
            'bookingDate': '2024-01-13 09:15',
            'travelDate': '2024-01-14 14:00',
            'status': 'completed',
            'totalAmount': 2400,
            'paymentStatus': 'paid',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load bookings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    items: _statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status == 'all' ? 'All Bookings' : status.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedStatus = value;
                        _loadBookings();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _loadBookings,
                  icon: const Icon(Icons.refresh),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Booking Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                _buildStatCard('Total Bookings', _bookings.length.toString(), Icons.book_online),
                const SizedBox(width: 12),
                _buildStatCard('Confirmed', _bookings.where((b) => b['status'] == 'confirmed').length.toString(), Icons.check_circle, Colors.green),
                const SizedBox(width: 12),
                _buildStatCard('Cancelled', _bookings.where((b) => b['status'] == 'cancelled').length.toString(), Icons.cancel, Colors.red),
              ],
            ),
          ),

          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadBookings,
                    child: _bookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book_online,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No bookings found',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _bookings.length,
                            itemBuilder: (context, index) => _buildBookingCard(_bookings[index]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, [Color? color]) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color ?? AppColors.primary, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color ?? AppColors.primary,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final statusColor = _getStatusColor(booking['status']);
    final paymentColor = _getPaymentColor(booking['paymentStatus']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.book_online,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking #${booking['id']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        booking['passengerName'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['status'].toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBookingInfo('Route', booking['route']),
                ),
                Expanded(
                  child: _buildBookingInfo('Vehicle', booking['vehicle']),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildBookingInfo('Seats', booking['seats'].join(', ')),
                ),
                Expanded(
                  child: _buildBookingInfo('Travel Date', booking['travelDate']),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildBookingInfo('Amount', 'Rs. ${booking['totalAmount']}'),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: paymentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking['paymentStatus'].toUpperCase(),
                      style: TextStyle(
                        color: paymentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _viewBookingDetails(booking),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Details'),
                ),
                const Spacer(),
                if (booking['status'] == 'confirmed')
                  TextButton.icon(
                    onPressed: () => _cancelBooking(booking),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                if (booking['paymentStatus'] == 'paid' && booking['status'] == 'confirmed')
                  TextButton.icon(
                    onPressed: () => _processRefund(booking),
                    icon: const Icon(Icons.undo),
                    label: const Text('Refund'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.warning,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.grey;
      case 'refunded':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'refunded':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _viewBookingDetails(Map<String, dynamic> booking) {
    // TODO: Navigate to booking details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking details for ${booking['passengerName']}')),
    );
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel the booking for ${booking['passengerName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement booking cancellation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Booking ${booking['id']} cancelled')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _processRefund(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Refund'),
        content: Text('Process refund of Rs. ${booking['totalAmount']} for booking ${booking['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement refund processing
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Refund processed for booking ${booking['id']}')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
            ),
            child: const Text('Process Refund'),
          ),
        ],
      ),
    );
  }
}
