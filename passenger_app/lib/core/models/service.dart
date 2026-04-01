enum ServiceStatus { active, inactive, suspended, pending }

class Service {
  final String id;
  final String name;
  final String description;
  final String type;
  final String routeId;
  final String vehicleId;
  final String driverId;
  final int capacity;
  final ServiceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data (populated from joins)
  final Map<String, dynamic>? route;
  final Map<String, dynamic>? vehicle;
  final Map<String, dynamic>? driver;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.routeId,
    required this.vehicleId,
    required this.driverId,
    required this.capacity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.route,
    this.vehicle,
    this.driver,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'bus',
      routeId: json['route_id']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      capacity: json['capacity'] ?? 0,
      status: ServiceStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ServiceStatus.active,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'route_id': routeId,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'capacity': capacity,
      'status': status.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Service copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? routeId,
    String? vehicleId,
    String? driverId,
    int? capacity,
    ServiceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? route,
    Map<String, dynamic>? vehicle,
    Map<String, dynamic>? driver,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      routeId: routeId ?? this.routeId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      route: route ?? this.route,
      vehicle: vehicle ?? this.vehicle,
      driver: driver ?? this.driver,
    );
  }

  String get routeName => route?['name'] ?? 'Unknown Route';
  String get vehicleNumber => vehicle?['registration_number'] ?? 'Unknown';
  String get driverName => driver?['full_name'] ?? 'Unassigned';
  bool get isActive => status == ServiceStatus.active;
  bool get isAvailable => status == ServiceStatus.active && driverId == null;
  bool get isInUse => driverId != null;
}