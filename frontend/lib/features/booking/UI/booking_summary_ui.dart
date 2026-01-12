import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../Data/seat_selection_data.dart';
import '../Logic/seat_selection_logic.dart';
import '../../../core/models/booking.dart';

class BookingSummaryUI extends StatefulWidget {
  final SeatSelectionData seatData;
  final double baseFare;
  final String busId;
  final String routeName;
  final DateTime travelDate;
  final String departureTime;
  final String arrivalTime;
  final String vehicleNumber;
  final String driverName;

  const BookingSummaryUI({
    super.key,
    required this.seatData,
    required this.baseFare,
    required this.busId,
    required this.routeName,
    required this.travelDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.vehicleNumber,
    required this.driverName,
  });

  @override
  State<BookingSummaryUI> createState() => _BookingSummaryUIState();
}

class _BookingSummaryUIState extends State<BookingSummaryUI> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalFare = widget.seatData.getTotalFare(widget.baseFare);

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
              "Booking Summary",
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route Information
                      _infoCard(
                        title: 'Route Information',
                        icon: Icons.route,
                        children: [
                          _infoRow('Route', widget.routeName),
                          _infoRow('Vehicle Type', widget.seatData.vehicleType == VehicleType.bus ? 'Bus' : 'Van'),
                          _infoRow('Vehicle Number', widget.vehicleNumber),
                          _infoRow('Driver', widget.driverName),
                        ],
                        cs: cs,
                      ),
                      const SizedBox(height: 16),

                      // Travel Details
                      _infoCard(
                        title: 'Travel Details',
                        icon: Icons.calendar_today,
                        children: [
                          _infoRow('Travel Date', _formatDate(widget.travelDate)),
                          _infoRow('Departure Time', widget.departureTime),
                          _infoRow('Arrival Time', widget.arrivalTime),
                          _infoRow('Selected Seats', widget.seatData.selectedSeatNumbers.join(', ')),
                        ],
                        cs: cs,
                      ),
                      const SizedBox(height: 16),

                      // Seat Details
                      _infoCard(
                        title: 'Seat Details',
                        icon: Icons.event_seat,
                        children: [
                          ...widget.seatData.selectedSeats.map((seat) =>
                            _infoRow('Seat ${seat.number}',
                              '${seat.gender == SeatGender.male ? 'Male' :
                                seat.gender == SeatGender.female ? 'Female' : 'General'} Section')
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: cs.outline.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  widget.seatData.vehicleType == VehicleType.bus
                                    ? Icons.directions_bus
                                    : Icons.airport_shuttle,
                                  color: cs.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${widget.seatData.selectedSeatNumbers.length} seat(s) selected',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        cs: cs,
                      ),
                      const SizedBox(height: 16),

                      // Fare Breakdown
                      _infoCard(
                        title: 'Fare Breakdown',
                        icon: Icons.payment,
                        children: [
                          _infoRow('Base Fare per Seat', 'Rs. ${widget.baseFare.toStringAsFixed(0)}'),
                          _infoRow('Number of Seats', '${widget.seatData.selectedSeatNumbers.length}'),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                              Text(
                                'Rs. ${totalFare.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        cs: cs,
                      ),
                      const SizedBox(height: 24),

                      // Important Notes
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightOrange.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColors.accentOrange, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Important Notes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _noteItem('• Seats will be held for 5 minutes after confirmation'),
                            _noteItem('• Please arrive 15 minutes before departure time'),
                            _noteItem('• Valid ID proof is required for boarding'),
                            _noteItem('• Cancellations are not allowed after payment'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _bottomBar(totalFare, cs),
            ],
          ),
        ),
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
            width: 120,
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

  Widget _noteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
          height: 1.4,
        ),
      ),
    );
  }

  Widget _bottomBar(double totalFare, ColorScheme cs) {
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
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Rs. ${totalFare.toStringAsFixed(0)}',
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
              onPressed: () => _proceedToPayment(),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Proceed to Payment',
                style: TextStyle(
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

  void _proceedToPayment() {
    // TODO: Navigate to payment screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proceeding to payment... (Payment screen to be implemented)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<bool> _handleBackPress(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go Back?'),
        content: const Text(
          'Are you sure you want to go back? Your booking summary will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Go Back'),
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
