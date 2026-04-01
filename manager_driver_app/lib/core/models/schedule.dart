enum ScheduleStatus { scheduled, inProgress, completed, cancelled, delayed }

class Schedule {
  final String id;
  final String serviceId;
  final String routeId;
  final String vehicleId;
  final String driverId;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final DateTime travelDate;
  final int availableSeats;
  final int totalSeats;
  final ScheduleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data (populated from joins)
  final Map<String, dynamic>? route;
  final Map<String, dynamic>? vehicle;
  final Map<String, dynamic>? driver;
  final Map<String, dynamic>? service;

  Schedule({
    required this.id,
    required this.serviceId,
    required this.routeId,
    required this.vehicleId,
    required this.driverId,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.travelDate,
    required this.availableSeats,
    required this.totalSeats,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.route,
    this.vehicle,
    this.driver,
    this.service,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      routeId: json['route_id']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      driverId: json['assigned_driver_id']?.toString() ?? '',
      origin: json['origin']?.toString() ?? 'Unknown',
      destination: json['destination']?.toString() ?? 'Unknown',
      departureTime: DateTime.parse(
        json['departure_time']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      arrivalTime: DateTime.parse(
        json['arrival_time']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      travelDate: DateTime.parse(
        json['travel_date']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      availableSeats: json['available_seats'] ?? 0,
      totalSeats: json['total_seats'] ?? 0,

      status: ScheduleStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ScheduleStatus.scheduled,
      ),
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      route: json['routes'],
      vehicle: json['vehicles'],
      driver: json['profiles'],
      service: json['services'] ?? json['vehicles']?['services'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'route_id': routeId,
      'vehicle_id': vehicleId,
      'assigned_driver_id': driverId,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'travel_date': travelDate.toIso8601String(),
      'available_seats': availableSeats,
      'total_seats': totalSeats,
      'status': status.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Schedule copyWith({
    String? id,
    String? serviceId,
    String? routeId,
    String? vehicleId,
    String? driverId,
    String? origin,
    String? destination,
    DateTime? departureTime,
    DateTime? arrivalTime,
    DateTime? travelDate,
    int? availableSeats,
    int? totalSeats,
    ScheduleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? route,
    Map<String, dynamic>? vehicle,
    Map<String, dynamic>? driver,
    Map<String, dynamic>? service,
  }) {
    return Schedule(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      routeId: routeId ?? this.routeId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      travelDate: travelDate ?? this.travelDate,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      route: route ?? this.route,
      vehicle: vehicle ?? this.vehicle,
      driver: driver ?? this.driver,
      service: service ?? this.service,
    );
  }

  String get routeName => '$origin → $destination';
  String get vehicleNumber => vehicle?['registration_number'] ?? 'Unknown';
  String get driverName => driver?['full_name'] ?? 'Unassigned';
  String get serviceName => service?['name'] ?? 'Unknown Service';

  bool get isFull => availableSeats == 0;
  bool get isUpcoming => departureTime.isAfter(DateTime.now());
  bool get isActive =>
      status == ScheduleStatus.inProgress || status == ScheduleStatus.scheduled;
}
