import '../../../core/models/booking.dart';

enum SeatStatus { available, booked, selected }

enum SeatGender { male, female, general }

class SeatModel {
  final int number;
  final SeatStatus status;
  final SeatGender gender;
  final bool isRemoved;

  const SeatModel({
    required this.number,
    required this.status,
    required this.gender,
    this.isRemoved = false,
  });

  SeatModel copyWith({
    int? number,
    SeatStatus? status,
    SeatGender? gender,
    bool? isRemoved,
  }) {
    return SeatModel(
      number: number ?? this.number,
      status: status ?? this.status,
      gender: gender ?? this.gender,
      isRemoved: isRemoved ?? this.isRemoved,
    );
  }

  bool get isAvailable => status == SeatStatus.available && !isRemoved;
  bool get isBooked => status == SeatStatus.booked;
  bool get isSelected => status == SeatStatus.selected;
}

class SeatSelectionData {
  final String busId;
  final VehicleType vehicleType;
  final List<SeatModel> seats;
  final List<int> selectedSeatNumbers;
  final int maxSeatsPerBooking;
  final int seatLockDurationMinutes;

  const SeatSelectionData({
    required this.busId,
    required this.vehicleType,
    required this.seats,
    required this.selectedSeatNumbers,
    this.maxSeatsPerBooking = 5,
    this.seatLockDurationMinutes = 5,
  });

  SeatSelectionData copyWith({
    String? busId,
    VehicleType? vehicleType,
    List<SeatModel>? seats,
    List<int>? selectedSeatNumbers,
    int? maxSeatsPerBooking,
    int? seatLockDurationMinutes,
  }) {
    return SeatSelectionData(
      busId: busId ?? this.busId,
      vehicleType: vehicleType ?? this.vehicleType,
      seats: seats ?? this.seats,
      selectedSeatNumbers: selectedSeatNumbers ?? this.selectedSeatNumbers,
      maxSeatsPerBooking: maxSeatsPerBooking ?? this.maxSeatsPerBooking,
      seatLockDurationMinutes: seatLockDurationMinutes ?? this.seatLockDurationMinutes,
    );
  }

  // Get selected seats
  List<SeatModel> get selectedSeats =>
      seats.where((seat) => seat.isSelected).toList();

  // Check if can select more seats
  bool get canSelectMore => selectedSeatNumbers.length < maxSeatsPerBooking;

  // Get total fare for selected seats
  double getTotalFare(double baseFare) {
    return selectedSeatNumbers.length * baseFare;
  }

  // Toggle seat selection
  SeatSelectionData toggleSeatSelection(int seatNumber) {
    final seat = seats.firstWhere((s) => s.number == seatNumber);

    if (!seat.isAvailable && !seat.isSelected) {
      // Cannot select unavailable or booked seats
      return this;
    }

    final isCurrentlySelected = seat.isSelected;
    final newSelectedNumbers = List<int>.from(selectedSeatNumbers);

    if (isCurrentlySelected) {
      newSelectedNumbers.remove(seatNumber);
    } else {
      if (!canSelectMore) return this; // Cannot select more than max
      newSelectedNumbers.add(seatNumber);
    }

    final newSeats = seats.map((s) {
      if (s.number == seatNumber) {
        return s.copyWith(
          status: isCurrentlySelected ? SeatStatus.available : SeatStatus.selected,
        );
      }
      return s;
    }).toList();

    return copyWith(
      seats: newSeats,
      selectedSeatNumbers: newSelectedNumbers,
    );
  }

  // Get seats by status count
  int getSeatsCount(SeatStatus status) =>
      seats.where((seat) => seat.status == status).length;

  // Validate selection
  bool get isValidSelection =>
      selectedSeatNumbers.isNotEmpty && selectedSeatNumbers.length <= maxSeatsPerBooking;
}
