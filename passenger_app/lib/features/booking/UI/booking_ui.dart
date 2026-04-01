import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../Data/booking_data.dart';
import '../Logic/booking_logic.dart';
import '../../../core/models/booking.dart';

class MyBookingPageUI extends StatefulWidget {
  const MyBookingPageUI({super.key});

  @override
  State<MyBookingPageUI> createState() => _MyBookingPageUIState();
}

class _MyBookingPageUIState extends State<MyBookingPageUI> {
  final MyBookingData _data = MyBookingData();

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      await _data.loadBookings();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Handle error - could show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bookings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () => MyBookingLogic.handleBackPress(context),
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
              "My Booking",
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () => MyBookingLogic.navigateToHome(context),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 5),
              _busVanTabs(cs),
              const SizedBox(height: 5),
              _paidUnpaidTabs(cs),
              const SizedBox(height: 10),
              Expanded(
                child: _bookingList(cs),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bus / Van toggle tabs
  Widget _busVanTabs(ColorScheme cs) {
    return Container(
      width: double.infinity,
      color: AppColors.lightOrange,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTab(
            label: "Bus",
            icon: Icons.directions_bus,
            selected: _data.isBusSelected,
            cs: cs,
            onTap: () => setState(() => _data.isBusSelected = true),
          ),
          const SizedBox(width: 8),
          _buildTab(
            label: "Van",
            icon: Icons.airport_shuttle,
            selected: !_data.isBusSelected,
            cs: cs,
            onTap: () => setState(() => _data.isBusSelected = false),
          ),
        ],
      ),
    );
  }

  /// Paid / Unpaid toggle tabs
  Widget _paidUnpaidTabs(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              avatar: const Icon(
                Icons.check_circle,
                color: AppColors.successGreen,
              ),
              label: const Text("Paid"),
              selected: _data.isPaidSelected,
              selectedColor: cs.primary,
              labelStyle: TextStyle(
                color: _data.isPaidSelected ? cs.onPrimary : cs.onSurface,
              ),
              onSelected: (_) => setState(() => _data.isPaidSelected = true),
              shape: const StadiumBorder(),
            ),
          ),
          Expanded(
            child: ChoiceChip(
              avatar: const Icon(
                Icons.timelapse_rounded,
                color: AppColors.error,
              ),
              label: const Text("Unpaid"),
              selected: !_data.isPaidSelected,
              selectedColor: cs.primary,
              labelStyle: TextStyle(
                color: !_data.isPaidSelected ? cs.onPrimary : cs.onSurface,
              ),
              onSelected: (_) => setState(() => _data.isPaidSelected = false),
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }

  /// Booking list
  Widget _bookingList(ColorScheme cs) {
    final filteredBookings = _data.getFilteredBookings();

    if (filteredBookings.isEmpty) {
      return _emptyBookingMessage(cs);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        return _bookingCard(booking, cs);
      },
    );
  }

  /// Booking card
  Widget _bookingCard(BookingModel booking, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => MyBookingLogic.navigateToBookingDetails(context, booking.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    booking.isBus ? Icons.directions_bus : Icons.airport_shuttle,
                    color: cs.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.routeName ?? 'Unknown Route',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: booking.isPaid ? AppColors.successGreen : AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.isPaid ? 'Paid' : 'Unpaid',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: cs.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.travelDate.day}/${booking.travelDate.month}/${booking.travelDate.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: cs.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    booking.departureTime ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: cs.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    'Seat: ${booking.seatNumber ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Rs. ${booking.fare.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty booking message
  Widget _emptyBookingMessage(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.6,
            child: Image.asset(
              _data.isBusSelected
                  ? "assets/bus/bus_icon.png"
                  : "assets/van/van_icon.png",
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  _data.isBusSelected ? Icons.directions_bus : Icons.airport_shuttle,
                  size: 120,
                  color: cs.onSurface.withOpacity(0.3),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _data.isPaidSelected
                ? "There is no any paid booking at the moment."
                : "There is no any unpaid booking at the moment.",
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Helper: Build a tab widget
  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool selected,
    required ColorScheme cs,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? cs.onPrimary : cs.onSurface.withOpacity(0.8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? cs.onPrimary : cs.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
