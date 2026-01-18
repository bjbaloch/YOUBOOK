import '../../../core/models/booking.dart';

enum SeatGender { male, female, general }

class Seat {
  final int number;
  final SeatGender gender;

  const Seat({
    required this.number,
    this.gender = SeatGender.general,
  });

  Map<String, dynamic> toJson() => {
    'number': number,
    'gender': gender.name,
  };

  factory Seat.fromJson(Map<String, dynamic> json) => Seat(
    number: json['number'] ?? 0,
    gender: SeatGender.values.firstWhere(
      (e) => e.name == json['gender'],
      orElse: () => SeatGender.general,
    ),
  );
}

class SeatSelectionData {
  final VehicleType vehicleType;
  final List<String> selectedSeatNumbers;
  final List<Seat> selectedSeats;
  final int totalSeats;
  final double pricePerSeat;
  final String serviceId;
  final String scheduleId;

  const SeatSelectionData({
    required this.vehicleType,
    required this.selectedSeatNumbers,
    required this.selectedSeats,
    required this.totalSeats,
    required this.pricePerSeat,
    required this.serviceId,
    required this.scheduleId,
  });

  // Calculate total price
  double get totalPrice => selectedSeatNumbers.length * pricePerSeat;

  // Calculate total fare with base fare
  double getTotalFare(double baseFare) => selectedSeatNumbers.length * baseFare;

  // Backward compatibility getter for busId (maps to scheduleId)
  String get busId => scheduleId;

  // Create a copy with updated selected seats
  SeatSelectionData copyWith({
    VehicleType? vehicleType,
    List<String>? selectedSeatNumbers,
    List<Seat>? selectedSeats,
    int? totalSeats,
    double? pricePerSeat,
    String? serviceId,
    String? scheduleId,
  }) {
    return SeatSelectionData(
      vehicleType: vehicleType ?? this.vehicleType,
      selectedSeatNumbers: selectedSeatNumbers ?? this.selectedSeatNumbers,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      serviceId: serviceId ?? this.serviceId,
      scheduleId: scheduleId ?? this.scheduleId,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType.name,
      'selectedSeatNumbers': selectedSeatNumbers,
      'totalSeats': totalSeats,
      'pricePerSeat': pricePerSeat,
      'serviceId': serviceId,
      'scheduleId': scheduleId,
    };
  }

  // Create from JSON
  factory SeatSelectionData.fromJson(Map<String, dynamic> json) {
    final selectedSeatNumbers = List<String>.from(json['selectedSeatNumbers'] ?? []);
    return SeatSelectionData(
      vehicleType: json['vehicleType'] == 'bus' ? VehicleType.bus : VehicleType.van,
      selectedSeatNumbers: selectedSeatNumbers,
      selectedSeats: selectedSeatNumbers.map((seatNum) => Seat(number: int.tryParse(seatNum) ?? 0)).toList(),
      totalSeats: json['totalSeats'] ?? 0,
      pricePerSeat: (json['pricePerSeat'] ?? 0.0).toDouble(),
      serviceId: json['serviceId'] ?? '',
      scheduleId: json['scheduleId'] ?? '',
    );
  }

  @override
  String toString() {
    return 'SeatSelectionData(vehicleType: $vehicleType, selectedSeats: $selectedSeatNumbers, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeatSelectionData &&
        other.vehicleType == vehicleType &&
        other.selectedSeatNumbers == selectedSeatNumbers &&
        other.totalSeats == totalSeats &&
        other.pricePerSeat == pricePerSeat &&
        other.serviceId == serviceId &&
        other.scheduleId == scheduleId;
  }

  @override
  int get hashCode {
    return Object.hash(
      vehicleType,
      selectedSeatNumbers,
      totalSeats,
      pricePerSeat,
      serviceId,
      scheduleId,
    );
  }
}
