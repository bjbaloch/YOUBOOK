import 'dart:math' as math;

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed;
  final double heading;
  final DateTime timestamp;
  final String vehicleId;
  final String driverId;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.timestamp,
    required this.vehicleId,
    required this.driverId,
  });

  // Create from JSON
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double? ?? 10.0,
      speed: json['speed'] as double? ?? 0.0,
      heading: json['heading'] as double? ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] as String),
      vehicleId: json['vehicle_id'] as String? ?? json['vehicleId'] as String,
      driverId: json['driver_id'] as String? ?? json['driverId'] as String,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'vehicle_id': vehicleId,
      'driver_id': driverId,
    };
  }

  // Create from Supabase broadcast payload
  factory LocationData.fromBroadcast(Map<String, dynamic> payload) {
    return LocationData(
      latitude: payload['latitude'] as double,
      longitude: payload['longitude'] as double,
      accuracy: payload['accuracy'] as double? ?? 10.0,
      speed: payload['speed'] as double? ?? 0.0,
      heading: payload['heading'] as double? ?? 0.0,
      timestamp: DateTime.parse(payload['timestamp'] as String),
      vehicleId: payload['vehicleId'] as String,
      driverId: payload['driverId'] as String,
    );
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, vehicle: $vehicleId, driver: $driverId, time: $timestamp)';
  }

  // Calculate distance to another location (in meters)
  double distanceTo(LocationData other) {
    const double earthRadius = 6371000; // meters

    final double lat1Rad = latitude * (math.pi / 180.0);
    final double lat2Rad = other.latitude * (math.pi / 180.0);
    final double deltaLatRad = (other.latitude - latitude) * (math.pi / 180.0);
    final double deltaLngRad = (other.longitude - longitude) * (math.pi / 180.0);

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // Check if location is recent (within last N minutes)
  bool isRecent({int minutes = 5}) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inMinutes <= minutes;
  }

  // Create a copy with updated fields
  LocationData copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? speed,
    double? heading,
    DateTime? timestamp,
    String? vehicleId,
    String? driverId,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
    );
  }
}
