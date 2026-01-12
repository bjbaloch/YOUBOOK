import 'package:flutter/material.dart';
import 'package:youbook/features/booking/UI/seat_selection_ui.dart';
import '../Data/seat_selection_data.dart';
import '../../../core/models/booking.dart';

class SeatSelectionLogic {
  // Mock data for demonstration - in real app this would come from API
  static SeatSelectionData getMockSeatData(String busId, VehicleType vehicleType) {
    List<SeatModel> seats;

    if (vehicleType == VehicleType.bus) {
      // Bus layout: 4x10 grid (40 seats)
      seats = List.generate(40, (index) {
        final number = index + 1;
        SeatStatus status;
        SeatGender gender;

        // Simulate some booked seats
        if ([5, 12, 18, 25, 33].contains(number)) {
          status = SeatStatus.booked;
        } else {
          status = SeatStatus.available;
        }

        // Simulate gender preferences
        if (number <= 10) {
          gender = SeatGender.female;
        } else if (number <= 20) {
          gender = SeatGender.male;
        } else {
          gender = SeatGender.general;
        }

        return SeatModel(
          number: number,
          status: status,
          gender: gender,
        );
      });
    } else {
      // Van layout: 15 seats with specific arrangement
      seats = List.generate(15, (index) {
        final number = index + 1;
        SeatStatus status;
        SeatGender gender;

        // Simulate some booked seats
        if ([3, 7, 11].contains(number)) {
          status = SeatStatus.booked;
        } else {
          status = SeatStatus.available;
        }

        // All van seats are general
        gender = SeatGender.general;

        return SeatModel(
          number: number,
          status: status,
          gender: gender,
        );
      });
    }

    return SeatSelectionData(
      busId: busId,
      vehicleType: vehicleType,
      seats: seats,
      selectedSeatNumbers: [],
    );
  }

  // Navigate to seat selection
  static void navigateToSeatSelection(
    BuildContext context,
    String busId,
    VehicleType vehicleType,
    double baseFare,
  ) {
    final seatData = getMockSeatData(busId, vehicleType);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeatSelectionUI(
          initialData: seatData,
          baseFare: baseFare,
        ),
      ),
    );
  }

  // Handle seat tap
  static SeatSelectionData handleSeatTap(SeatSelectionData data, int seatNumber) {
    return data.toggleSeatSelection(seatNumber);
  }

  // Validate and proceed to booking summary
  static void proceedToBookingSummary(
    BuildContext context,
    SeatSelectionData seatData,
    double baseFare,
  ) {
    if (!seatData.isValidSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one seat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Navigate to booking summary screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Selected ${seatData.selectedSeatNumbers.length} seats. Proceeding to summary...',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // For now, just pop back
    Navigator.pop(context);
  }

  // Get seat color based on status
  static Color getSeatColor(SeatModel seat, ColorScheme cs) {
    switch (seat.status) {
      case SeatStatus.available:
        return seat.isRemoved ? cs.surfaceVariant : Colors.green.shade200;
      case SeatStatus.booked:
        return Colors.red.shade200;
      case SeatStatus.selected:
        return cs.primary;
    }
  }

  // Get seat border color
  static Color getSeatBorderColor(SeatModel seat, ColorScheme cs) {
    switch (seat.status) {
      case SeatStatus.available:
        return seat.isRemoved ? cs.outlineVariant : Colors.green;
      case SeatStatus.booked:
        return Colors.red;
      case SeatStatus.selected:
        return cs.primary;
    }
  }

  // Get seat text color
  static Color getSeatTextColor(SeatModel seat, ColorScheme cs) {
    if (seat.isRemoved) {
      return cs.onSurface.withOpacity(0.5);
    }

    switch (seat.status) {
      case SeatStatus.available:
        return Colors.black87;
      case SeatStatus.booked:
        return Colors.red.shade900;
      case SeatStatus.selected:
        return cs.onPrimary;
    }
  }

  // Get gender icon
  static IconData? getGenderIcon(SeatGender gender) {
    switch (gender) {
      case SeatGender.male:
        return Icons.male;
      case SeatGender.female:
        return Icons.female;
      case SeatGender.general:
        return null;
    }
  }

  // Format seat selection summary
  static String getSelectionSummary(SeatSelectionData data) {
    final selected = data.selectedSeatNumbers;
    if (selected.isEmpty) return 'No seats selected';

    selected.sort();
    return 'Seats: ${selected.join(', ')} (${selected.length})';
  }

  // Check if seat is selectable
  static bool isSeatSelectable(SeatModel seat) {
    return seat.isAvailable || seat.isSelected;
  }
}
