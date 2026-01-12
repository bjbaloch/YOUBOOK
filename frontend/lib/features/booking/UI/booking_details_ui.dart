import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../Data/booking_data.dart';
import '../Logic/booking_logic.dart';
import '../../../core/models/booking.dart';

class BookingDetailsUI extends StatelessWidget {
  final String bookingId;

  const BookingDetailsUI({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final booking = MyBookingData().getBookingById(bookingId);

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Booking Details'),
          backgroundColor: cs.primary,
        ),
        body: const Center(
          child: Text('Booking not found'),
        ),
      );
    }

    return Scaffold(
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
            "Booking Details",
            style: TextStyle(
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _statusCard(booking, cs),
              const SizedBox(height: 16),

              // Route Information
              _infoCard(
                title: 'Route Information',
                icon: Icons.route,
                children: [
                  _infoRow('Route', booking.routeName ?? 'Unknown Route'),
                  _infoRow('Vehicle Type', booking.isBus ? 'Bus' : 'Van'),
                  _infoRow('Vehicle Number', booking.vehicleNumber ?? 'N/A'),
                  _infoRow('Driver', booking.driverName ?? 'N/A'),
                ],
                cs: cs,
              ),
              const SizedBox(height: 16),

              // Travel Details
              _infoCard(
                title: 'Travel Details',
                icon: Icons.calendar_today,
                children: [
                  _infoRow('Travel Date', _formatDate(booking.travelDate)),
                  _infoRow('Departure Time', booking.departureTime ?? 'N/A'),
                  _infoRow('Arrival Time', booking.arrivalTime ?? 'N/A'),
                  _infoRow('Seat Number', booking.seatNumber ?? 'N/A'),
                ],
                cs: cs,
              ),
              const SizedBox(height: 16),

              // Payment Information
              _infoCard(
                title: 'Payment Information',
                icon: Icons.payment,
                children: [
                  _infoRow('Fare', 'Rs. ${booking.fare.toStringAsFixed(0)}'),
                  _infoRow('Status', booking.isPaid ? 'Paid' : 'Unpaid'),
                  _infoRow('Booking Date', _formatDate(booking.bookingDate)),
                ],
                cs: cs,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              if (!booking.isPaid) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement payment
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment feature coming soon')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Pay Now',
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implement cancel booking
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cancel booking feature coming soon')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel Booking',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCard(BookingModel booking, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: booking.isPaid ? AppColors.successGreen : AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            booking.isPaid ? Icons.check_circle : Icons.schedule,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.isPaid ? 'Booking Confirmed' : 'Payment Pending',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  booking.isPaid
                      ? 'Your booking is confirmed and paid'
                      : 'Please complete your payment to confirm booking',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required ColorScheme cs,
  }) {
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
                Icon(icon, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
