enum VehicleType {
  bus,
  van,
  miniBus,
}

enum VehicleStatus {
  active,
  maintenance,
  inactive,
  outOfService,
}

class Vehicle {
  final String id;
  final String serviceId;
  final String registrationNumber;
  final VehicleType type;
  final String make;
  final String model;
  final int year;
  final int capacity;
  final VehicleStatus status;
  final String? currentDriverId;
  final String? currentLocation;
  final double? latitude;
  final double? longitude;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final int totalKm;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? currentDriver;

  Vehicle({
    required this.id,
    required this.serviceId,
    required this.registrationNumber,
    required this.type,
    required this.make,
    required this.model,
    required this.year,
    required this.capacity,
    required this.status,
    this.currentDriverId,
    this.currentLocation,
    this.latitude,
    this.longitude,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    required this.totalKm,
    required this.createdAt,
    required this.updatedAt,
    this.service,
    this.currentDriver,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      registrationNumber: json['registration_number']?.toString() ?? '',
      type: VehicleType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => VehicleType.bus,
      ),
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: json['year'] ?? DateTime.now().year,
      capacity: json['capacity'] ?? 0,
      status: VehicleStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => VehicleStatus.active,
      ),
      currentDriverId: json['current_driver_id']?.toString(),
      currentLocation: json['current_location']?.toString(),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      lastMaintenanceDate: json['last_maintenance_date'] != null
          ? DateTime.parse(json['last_maintenance_date'].toString())
          : null,
      nextMaintenanceDate: json['next_maintenance_date'] != null
          ? DateTime.parse(json['next_maintenance_date'].toString())
          : null,
      totalKm: json['total_km'] ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      service: json['services'],
      currentDriver: json['current_driver'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'registration_number': registrationNumber,
      'type': type.toString(),
      'make': make,
      'model': model,
      'year': year,
      'capacity': capacity,
      'status': status.toString(),
      'current_driver_id': currentDriverId,
      'current_location': currentLocation,
      'latitude': latitude,
      'longitude': longitude,
      'last_maintenance_date': lastMaintenanceDate?.toIso8601String(),
      'next_maintenance_date': nextMaintenanceDate?.toIso8601String(),
      'total_km': totalKm,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Vehicle copyWith({
    String? id,
    String? serviceId,
    String? registrationNumber,
    VehicleType? type,
    String? make,
    String? model,
    int? year,
    int? capacity,
    VehicleStatus? status,
    String? currentDriverId,
    String? currentLocation,
    double? latitude,
    double? longitude,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    int? totalKm,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? service,
    Map<String, dynamic>? currentDriver,
  }) {
    return Vehicle(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      type: type ?? this.type,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentDriverId: currentDriverId ?? this.currentDriverId,
      currentLocation: currentLocation ?? this.currentLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      totalKm: totalKm ?? this.totalKm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      service: service ?? this.service,
      currentDriver: currentDriver ?? this.currentDriver,
    );
  }

  String get displayName => '$registrationNumber ($make $model)';
  String get driverName => currentDriver?['full_name'] ?? 'No Driver Assigned';
  String get serviceName => service?['name'] ?? 'Unknown Service';
  bool get needsMaintenance => nextMaintenanceDate?.isBefore(DateTime.now()) ?? false;
  bool get isAvailable => status == VehicleStatus.active && currentDriverId == null;
  bool get isInUse => currentDriverId != null;
}
