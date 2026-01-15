enum DriverStatus {
  idle,
  assigned,
  onTrip,
}

class Driver {
  final String id;
  final String userId;
  final String managerId;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String phoneNumber;
  final String emergencyContact;
  final DriverStatus status;
  final String? currentVehicleId;
  final String? currentScheduleId;
  final DateTime? lastActiveAt;
  final int totalTrips;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? currentVehicle;
  final Map<String, dynamic>? currentSchedule;

  Driver({
    required this.id,
    required this.userId,
    required this.managerId,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.phoneNumber,
    required this.emergencyContact,
    required this.status,
    this.currentVehicleId,
    this.currentScheduleId,
    this.lastActiveAt,
    required this.totalTrips,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.currentVehicle,
    this.currentSchedule,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    // Map database status to enum
    DriverStatus status;
    final statusStr = json['current_status']?.toString() ?? 'Idle';
    switch (statusStr) {
      case 'Idle':
        status = DriverStatus.idle;
        break;
      case 'Assigned':
        status = DriverStatus.assigned;
        break;
      case 'On Trip':
        status = DriverStatus.onTrip;
        break;
      default:
        status = DriverStatus.idle;
    }

    return Driver(
      id: json['id']?.toString() ?? '',
      userId: json['auth_user_id']?.toString() ?? '',
      managerId: json['company_id']?.toString() ?? '',
      licenseNumber: json['license_number']?.toString() ?? '',
      licenseExpiry: DateTime.now().add(const Duration(days: 365)), // Placeholder - not in schema
      phoneNumber: json['phone']?.toString() ?? '',
      emergencyContact: '', // Not in schema
      status: status,
      currentVehicleId: null, // Not in schema
      currentScheduleId: null, // Not in schema
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'].toString())
          : null,
      totalTrips: json['total_trips'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      user: json['profiles'], // Join with profiles table
      currentVehicle: null,
      currentSchedule: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'manager_id': managerId,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry.toIso8601String(),
      'phone_number': phoneNumber,
      'emergency_contact': emergencyContact,
      'status': status.toString(),
      'current_vehicle_id': currentVehicleId,
      'current_schedule_id': currentScheduleId,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'total_trips': totalTrips,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Driver copyWith({
    String? id,
    String? userId,
    String? managerId,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? phoneNumber,
    String? emergencyContact,
    DriverStatus? status,
    String? currentVehicleId,
    String? currentScheduleId,
    DateTime? lastActiveAt,
    int? totalTrips,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? user,
    Map<String, dynamic>? currentVehicle,
    Map<String, dynamic>? currentSchedule,
  }) {
    return Driver(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      managerId: managerId ?? this.managerId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      status: status ?? this.status,
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
      currentScheduleId: currentScheduleId ?? this.currentScheduleId,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalTrips: totalTrips ?? this.totalTrips,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      currentVehicle: currentVehicle ?? this.currentVehicle,
      currentSchedule: currentSchedule ?? this.currentSchedule,
    );
  }

  String get fullName => user?['full_name'] ?? 'Unknown Driver';
  String get email => user?['email'] ?? '';
  String get currentVehicleNumber => currentVehicle?['registration_number'] ?? 'Not Assigned';
  bool get isLicenseValid => licenseExpiry.isAfter(DateTime.now());
  bool get isAvailable => status == DriverStatus.idle && currentScheduleId == null;
  bool get isOnDuty => currentScheduleId != null;
}
