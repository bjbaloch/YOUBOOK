import 'package:uuid/uuid.dart';

enum BookingStatus { confirmed, cancelled, completed, pending }
enum VehicleType { bus, van }

class BookingModel {
  final String id;
  final String passengerId;
  final String routeId;
  final String? routeName;
  final VehicleType vehicleType;
  final BookingStatus status;
  final DateTime bookingDate;
  final DateTime travelDate;
  final String? departureTime;
  final String? arrivalTime;
  final double fare;
  final String? seatNumber;
  final String? driverName;
  final String? vehicleNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    String? id,
    required this.passengerId,
    required this.routeId,
    this.routeName,
    required this.vehicleType,
    required this.status,
    required this.bookingDate,
    required this.travelDate,
    this.departureTime,
    this.arrivalTime,
    required this.fare,
    this.seatNumber,
    this.driverName,
    this.vehicleNumber,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString(),
      passengerId: json['passenger_id']?.toString() ?? '',
      routeId: json['route_id']?.toString() ?? '',
      routeName: json['route_name']?.toString(),
      vehicleType: json['vehicle_type'] == 'van' ? VehicleType.van : VehicleType.bus,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
        orElse: () => BookingStatus.pending,
      ),
      bookingDate: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'].toString())
          : DateTime.now(),
      travelDate: json['travel_date'] != null
          ? DateTime.parse(json['travel_date'].toString())
          : DateTime.now(),
      departureTime: json['departure_time']?.toString(),
      arrivalTime: json['arrival_time']?.toString(),
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      seatNumber: json['seat_number']?.toString(),
      driverName: json['driver_name']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passenger_id': passengerId,
      'route_id': routeId,
      'route_name': routeName,
      'vehicle_type': vehicleType == VehicleType.van ? 'van' : 'bus',
      'status': status.toString().split('.').last,
      'booking_date': bookingDate.toIso8601String(),
      'travel_date': travelDate.toIso8601String(),
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'fare': fare,
      'seat_number': seatNumber,
      'driver_name': driverName,
      'vehicle_number': vehicleNumber,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? passengerId,
    String? routeId,
    String? routeName,
    VehicleType? vehicleType,
    BookingStatus? status,
    DateTime? bookingDate,
    DateTime? travelDate,
    String? departureTime,
    String? arrivalTime,
    double? fare,
    String? seatNumber,
    String? driverName,
    String? vehicleNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      travelDate: travelDate ?? this.travelDate,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      fare: fare ?? this.fare,
      seatNumber: seatNumber ?? this.seatNumber,
      driverName: driverName ?? this.driverName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isPending => status == BookingStatus.pending;

  // Backward compatibility getters for existing UI code
  bool get isPaid => status == BookingStatus.confirmed || status == BookingStatus.completed;
  bool get isUnpaid => status == BookingStatus.pending;
  bool get isBus => vehicleType == VehicleType.bus;
  bool get isVan => vehicleType == VehicleType.van;

  @override
  String toString() {
    return 'BookingModel(id: $id, routeName: $routeName, vehicleType: $vehicleType, status: $status, fare: $fare)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookingModel &&
        other.id == id &&
        other.passengerId == passengerId &&
        other.routeId == routeId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ passengerId.hashCode ^ routeId.hashCode;
  }
}
