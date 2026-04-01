import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/location_data.dart';

class VehicleStatus {
  final String vehicleId;
  final String vehicleNumber;
  final String driverId;
  final String driverName;
  final String status;
  final LocationData? lastLocation;
  final DateTime lastUpdated;
  final int passengerCount;
  final double fuelLevel;
  final String route;

  const VehicleStatus({
    required this.vehicleId,
    required this.vehicleNumber,
    required this.driverId,
    required this.driverName,
    required this.status,
    this.lastLocation,
    required this.lastUpdated,
    required this.passengerCount,
    required this.fuelLevel,
    required this.route,
  });

  factory VehicleStatus.fromJson(Map<String, dynamic> json) {
    return VehicleStatus(
      vehicleId: json['vehicle_id'] as String,
      vehicleNumber: json['vehicle_number'] as String,
      driverId: json['driver_id'] as String,
      driverName: json['driver_name'] as String,
      status: json['status'] as String,
      lastLocation: json['last_location'] != null
          ? LocationData.fromJson(json['last_location'])
          : null,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      passengerCount: json['passenger_count'] as int? ?? 0,
      fuelLevel: (json['fuel_level'] as num?)?.toDouble() ?? 0.0,
      route: json['route'] as String? ?? '',
    );
  }
}

class FleetAnalytics {
  final int totalVehicles;
  final int activeVehicles;
  final int totalDrivers;
  final int activeDrivers;
  final double averageFuelEfficiency;
  final double totalRevenue;
  final double onTimePerformance;
  final int totalTripsToday;

  const FleetAnalytics({
    required this.totalVehicles,
    required this.activeVehicles,
    required this.totalDrivers,
    required this.activeDrivers,
    required this.averageFuelEfficiency,
    required this.totalRevenue,
    required this.onTimePerformance,
    required this.totalTripsToday,
  });

  factory FleetAnalytics.fromJson(Map<String, dynamic> json) {
    return FleetAnalytics(
      totalVehicles: json['total_vehicles'] as int? ?? 0,
      activeVehicles: json['active_vehicles'] as int? ?? 0,
      totalDrivers: json['total_drivers'] as int? ?? 0,
      activeDrivers: json['active_drivers'] as int? ?? 0,
      averageFuelEfficiency: (json['avg_fuel_efficiency'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      onTimePerformance: (json['on_time_performance'] as num?)?.toDouble() ?? 0.0,
      totalTripsToday: json['total_trips_today'] as int? ?? 0,
    );
  }
}

class RealtimeFleetService {
  static final RealtimeFleetService _instance = RealtimeFleetService._internal();
  factory RealtimeFleetService() => _instance;
  RealtimeFleetService._internal();

  final StreamController<List<VehicleStatus>> _fleetStatusController = StreamController<List<VehicleStatus>>.broadcast();
  final StreamController<FleetAnalytics> _analyticsController = StreamController<FleetAnalytics>.broadcast();
  final StreamController<Map<String, dynamic>> _alertsController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<List<VehicleStatus>> get fleetStatusStream => _fleetStatusController.stream;
  Stream<FleetAnalytics> get analyticsStream => _analyticsController.stream;
  Stream<Map<String, dynamic>> get alertsStream => _alertsController.stream;

  Timer? _statusUpdateTimer;
  Timer? _analyticsUpdateTimer;

  void initializeFleetMonitoring() {
    _startFleetStatusUpdates();
    _startAnalyticsUpdates();
  }

  void _startFleetStatusUpdates() {
    _statusUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchFleetStatus(),
    );
    _fetchFleetStatus();
  }

  Future<void> _fetchFleetStatus() async {
    // TODO: Restore Supabase query when connecting backend
    debugPrint('Fleet status fetch skipped in UI-only mode');
  }

  void _startAnalyticsUpdates() {
    _analyticsUpdateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _fetchAnalytics(),
    );
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    // TODO: Restore Supabase query when connecting backend
    debugPrint('Analytics fetch skipped in UI-only mode');
  }

  Future<Map<String, dynamic>?> getVehicleDetails(String vehicleId) async {
    // TODO: Restore Supabase query when connecting backend
    return null;
  }

  Future<void> updateVehicleStatus({
    required String vehicleId,
    required String status,
    String? notes,
  }) async {
    // TODO: Restore Supabase update when connecting backend
    _fetchFleetStatus();
  }

  Future<void> sendDriverAlert({
    required String driverId,
    required String message,
    required String priority,
  }) async {
    // TODO: Restore Supabase insert when connecting backend
    await _sendDriverNotification(driverId, message, priority);
  }

  Future<void> _sendDriverNotification(String driverId, String message, String priority) async {
    debugPrint('Sending notification to driver $driverId: $message');
  }

  Future<Map<String, dynamic>> getFleetPerformance({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // TODO: Restore Supabase RPC when connecting backend
    return {};
  }

  Future<List<Map<String, dynamic>>> getMaintenanceSchedule() async {
    // TODO: Restore Supabase query when connecting backend
    return [];
  }

  void stopFleetMonitoring() {
    _statusUpdateTimer?.cancel();
    _analyticsUpdateTimer?.cancel();
    _statusUpdateTimer = null;
    _analyticsUpdateTimer = null;
  }

  void dispose() {
    stopFleetMonitoring();
    _fleetStatusController.close();
    _analyticsController.close();
    _alertsController.close();
  }
}
