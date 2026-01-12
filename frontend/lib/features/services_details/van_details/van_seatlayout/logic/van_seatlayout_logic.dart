// logic.dart
import 'dart:convert';
import 'package:youbook/features/services_details/van_details/van_seatlayout/Data/van_seatlayout_data.dart';

class VanSeatLayoutController {
  String numberingMode = 'Auto';
  List<Seat> seats = List.generate(
    totalSeats,
    (index) => Seat(number: index + 1),
  );

  /// Create fixed seat plan (Auto or Manual)
  void createFixedSeatPlan() {
    final isManual = numberingMode == 'Manual';
    seats = List.generate(
      totalSeats,
      (i) => Seat(number: isManual ? 0 : i + 1),
    );
  }

  /// Toggle seat removed/un-removed
  void toggleSeatRemoved(int index) {
    if (index < 0 || index >= seats.length) return;
    seats[index].removed = !seats[index].removed;
  }

  /// Remove single seat
  void removeSingleSeat(int index) {
    if (index < 0 || index >= seats.length) return;
    seats[index].removed = true;
  }

  /// Remove all seats
  void removeAllSeats() {
    for (var seat in seats) {
      seat.removed = true;
    }
  }

  /// Generate JSON of the layout
  String getSeatLayoutJson() {
    final layout = {
      'layoutType': 'Van-15-Seater',
      'driverSide': driverSide,
      'numberingMode': numberingMode,
      'totalSeats': seats.length,
      'seats': seats.map((s) => s.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(layout);
  }

  /// Validate seat layout
  bool isValidLayout() => seats.isNotEmpty && seats.length == totalSeats;
}
