import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as printing;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../Data/seat_selection_data.dart';
import '../../../core/models/booking.dart';

class BookingReceiptUI extends StatefulWidget {
  final SeatSelectionData seatData;
  final double totalAmount;
  final String routeName;
  final DateTime travelDate;
  final String departureTime;
  final String arrivalTime;
  final String vehicleNumber;
  final String driverName;
  final String bookingId;
  final DateTime bookingDate;
  final String paymentMethod;

  const BookingReceiptUI({
    super.key,
    required this.seatData,
    required this.totalAmount,
    required this.routeName,
    required this.travelDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.vehicleNumber,
    required this.driverName,
    required this.bookingId,
    required this.bookingDate,
    required this.paymentMethod,
  });

  @override
  State<BookingReceiptUI> createState() => _BookingReceiptUIState();
}

class _BookingReceiptUIState extends State<BookingReceiptUI>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
              "Booking Confirmed",
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.home, color: cs.onPrimary),
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _successHeader(cs),
                    const SizedBox(height: 24),
                    _bookingCard(cs),
                    const SizedBox(height: 24),
                    _qrCodeSection(cs),
                    const SizedBox(height: 24),
                    _actionButtons(cs),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _successHeader(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Booking Confirmed!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your seats have been successfully booked',
            style: TextStyle(fontSize: 16, color: Colors.green.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(ColorScheme cs) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with booking ID
            Row(
              children: [
                Icon(Icons.confirmation_number, color: cs.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Booking ID: ${widget.bookingId}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Paid',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Route Information
            _infoSection(
              title: 'Route Information',
              icon: Icons.route,
              children: [
                _infoRow('Route', widget.routeName),
                _infoRow(
                  'Vehicle Type',
                  widget.seatData.vehicleType == VehicleType.bus
                      ? 'Bus'
                      : 'Van',
                ),
                _infoRow('Vehicle Number', widget.vehicleNumber),
                _infoRow('Driver', widget.driverName),
              ],
              cs: cs,
            ),
            const SizedBox(height: 16),

            // Travel Details
            _infoSection(
              title: 'Travel Details',
              icon: Icons.calendar_today,
              children: [
                _infoRow('Travel Date', _formatDate(widget.travelDate)),
                _infoRow('Departure Time', widget.departureTime),
                _infoRow('Arrival Time', widget.arrivalTime),
                _infoRow(
                  'Selected Seats',
                  widget.seatData.selectedSeatNumbers.join(', '),
                ),
              ],
              cs: cs,
            ),
            const SizedBox(height: 16),

            // Payment Details
            _infoSection(
              title: 'Payment Details',
              icon: Icons.payment,
              children: [
                _infoRow('Payment Method', widget.paymentMethod),
                _infoRow('Booking Date', _formatDateTime(widget.bookingDate)),
                _infoRow(
                  'Total Amount',
                  'Rs. ${widget.totalAmount.toStringAsFixed(0)}',
                ),
                _infoRow('Status', 'Confirmed'),
              ],
              cs: cs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required ColorScheme cs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: cs.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrCodeSection(ColorScheme cs) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Booking QR Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Show this QR code at the boarding point',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline.withOpacity(0.3)),
              ),
              child: QrImageView(
                data: widget.bookingId,
                version: QrVersions.auto,
                size: 150.0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.bookingId,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons(ColorScheme cs) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareBooking,
            icon: const Icon(Icons.share),
            label: const Text('Share Booking Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _downloadReceipt,
            icon: const Icon(Icons.download),
            label: const Text('Download Receipt'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cs.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.home),
            label: const Text('Back to Home'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _shareBooking() async {
    try {
      final shareText =
          '''
YouBook Bus Ticket

Booking ID: ${widget.bookingId}
Route: ${widget.routeName}
Date: ${_formatDate(widget.travelDate)}
Time: ${widget.departureTime}
Seats: ${widget.seatData.selectedSeatNumbers.join(', ')}
Vehicle: ${widget.vehicleNumber}
Amount: Rs. ${widget.totalAmount.toStringAsFixed(0)}

Show QR code at boarding point.
''';

      await Share.share(
        shareText,
        subject: 'YouBook Bus Ticket - ${widget.bookingId}',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking details shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadReceipt() async {
    try {
      // Generate PDF
      final pdf = pw.Document();

      // Add page with ticket details
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    'YouBook Bus Ticket',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Booking ID
                pw.Text(
                  'Booking ID: ${widget.bookingId}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Route Information
                pw.Text(
                  'Route: ${widget.routeName}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Vehicle Type: ${widget.seatData.vehicleType == VehicleType.bus ? 'Bus' : 'Van'}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Vehicle Number: ${widget.vehicleNumber}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Driver: ${widget.driverName}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 10),

                // Travel Details
                pw.Text(
                  'Travel Date: ${_formatDate(widget.travelDate)}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Departure Time: ${widget.departureTime}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Arrival Time: ${widget.arrivalTime}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Selected Seats: ${widget.seatData.selectedSeatNumbers.join(', ')}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 10),

                // Payment Details
                pw.Text(
                  'Payment Method: ${widget.paymentMethod}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Booking Date: ${_formatDateTime(widget.bookingDate)}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Total Amount: Rs. ${widget.totalAmount.toStringAsFixed(0)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                // QR Code placeholder
                pw.Center(
                  child: pw.Container(
                    width: 100,
                    height: 100,
                    decoration: pw.BoxDecoration(border: pw.Border.all()),
                    child: pw.Center(
                      child: pw.Text(
                        'QR Code\n${widget.bookingId}',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Show this QR code at the boarding point',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Show PDF preview/print dialog
      if (context.mounted) {
        await printing.Printing.layoutPdf(
          onLayout: (format) async => pdf.save(),
          name: 'YouBook_Ticket_${widget.bookingId}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download ticket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _handleBackPress(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit to Home?'),
        content: const Text(
          'Are you sure you want to go back to home? You can view your booking details in the My Bookings section.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay Here'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );

    if (result == true) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    return false;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
