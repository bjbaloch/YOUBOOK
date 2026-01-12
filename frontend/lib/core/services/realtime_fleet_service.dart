import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_data.dart';

class VehicleStatus {
  final String vehicleId;
  final String vehicleNumber;
  final String driverId;
  final String driverName;
  final String status; // 'active', 'inactive', 'maintenance', 'offline'
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

  final SupabaseClient _supabase = Supabase.instance.client;

  // Stream controllers
  final StreamController<List<VehicleStatus>> _fleetStatusController = StreamController<List<VehicleStatus>>.broadcast();
  final StreamController<FleetAnalytics> _analyticsController = StreamController<FleetAnalytics>.broadcast();
  final StreamController<Map<String, dynamic>> _alertsController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<List<VehicleStatus>> get fleetStatusStream => _fleetStatusController.stream;
  Stream<FleetAnalytics> get analyticsStream => _analyticsController.stream;
  Stream<Map<String, dynamic>> get alertsStream => _alertsController.stream;

  Timer? _statusUpdateTimer;
  Timer? _analyticsUpdateTimer;

  // Initialize fleet monitoring
  void initializeFleetMonitoring() {
    _startFleetStatusUpdates();
    _startAnalyticsUpdates();
    _startAlertMonitoring();
  }

  // Start fleet status updates
  void _startFleetStatusUpdates() {
    _statusUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchFleetStatus(),
    );

    // Initial fetch
    _fetchFleetStatus();
  }

  // Fetch current fleet status
  Future<void> _fetchFleetStatus() async {
    try {
      // Get all vehicles with their current status
      final response = await _supabase
        .from('vehicle_status')
        .select('''
          *,
          vehicles (
            vehicle_number,
            routes (route_name)
          ),
          drivers (
            name
          )
        ''');

      final fleetStatus = response.map((json) => VehicleStatus.fromJson(json)).toList();
      _fleetStatusController.add(fleetStatus);
    } catch (e) {
      debugPrint('Error fetching fleet status: $e');
    }
  }

  // Start analytics updates
  void _startAnalyticsUpdates() {
    _analyticsUpdateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _fetchAnalytics(),
    );

    // Initial fetch
    _fetchAnalytics();
  }

  // Fetch fleet analytics
  Future<void> _fetchAnalytics() async {
    try {
      final response = await _supabase
        .from('fleet_analytics')
        .select()
        .single();

      final analytics = FleetAnalytics.fromJson(response);
      _analyticsController.add(analytics);
    } catch (e) {
      debugPrint('Error fetching analytics: $e');
    }
  }

  // Start alert monitoring
  void _startAlertMonitoring() {
    // Monitor for alerts like low fuel, maintenance due, etc.
    _checkForAlerts();
  }

  // Check for system alerts
  Future<void> _checkForAlerts() async {
    try {
      // Check low fuel alerts
      final lowFuelResponse = await _supabase
        .from('vehicles')
        .select('vehicle_number, fuel_level')
        .lt('fuel_level', 20);

      for (final vehicle in lowFuelResponse) {
        _alertsController.add({
          'type': 'low_fuel',
          'vehicle': vehicle['vehicle_number'],
          'message': 'Low fuel level: ${vehicle['fuel_level']}%',
          'severity': 'warning',
          'timestamp': DateTime.now(),
        });
      }

      // Check maintenance due alerts
      final maintenanceResponse = await _supabase
        .from('vehicle_maintenance')
        .select('vehicles(vehicle_number), due_date')
        .lte('due_date', DateTime.now().add(const Duration(days: 7)).toIso8601String());

      for (final maintenance in maintenanceResponse) {
        _alertsController.add({
          'type': 'maintenance_due',
          'vehicle': maintenance['vehicles']['vehicle_number'],
          'message': 'Maintenance due soon',
          'severity': 'info',
          'timestamp': DateTime.now(),
        });
      }

    } catch (e) {
      debugPrint('Error checking alerts: $e');
    }
  }

  // Get detailed vehicle information
  Future<Map<String, dynamic>?> getVehicleDetails(String vehicleId) async {
    try {
      final response = await _supabase
        .from('vehicles')
        .select('''
          *,
          drivers (
            name,
            phone,
            rating
          ),
          routes (
            route_name,
            distance
          )
        ''')
        .eq('id', vehicleId)
        .single();

      return response;
    } catch (e) {
      debugPrint('Error getting vehicle details: $e');
      return null;
    }
  }

  // Update vehicle status
  Future<void> updateVehicleStatus({
    required String vehicleId,
    required String status,
    String? notes,
  }) async {
    try {
      await _supabase
        .from('vehicle_status')
        .update({
          'status': status,
          'notes': notes,
          'last_updated': DateTime.now().toIso8601String(),
        })
        .eq('vehicle_id', vehicleId);

      // Refresh fleet status
      _fetchFleetStatus();
    } catch (e) {
      debugPrint('Error updating vehicle status: $e');
    }
  }

  // Send driver alert
  Future<void> sendDriverAlert({
    required String driverId,
    required String message,
    required String priority, // 'low', 'medium', 'high'
  }) async {
    try {
      await _supabase
        .from('driver_alerts')
        .insert({
          'driver_id': driverId,
          'message': message,
          'priority': priority,
          'created_at': DateTime.now().toIso8601String(),
          'is_read': false,
        });

      // Send push notification
      await _sendDriverNotification(driverId, message, priority);
    } catch (e) {
      debugPrint('Error sending driver alert: $e');
    }
  }

  // Send push notification to driver
  Future<void> _sendDriverNotification(String driverId, String message, String priority) async {
    // Implementation would send push notification via FCM
    debugPrint('Sending notification to driver $driverId: $message');
  }

  // Get fleet performance metrics
  Future<Map<String, dynamic>> getFleetPerformance({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase.rpc('get_fleet_performance', params: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting fleet performance: $e');
      return {};
    }
  }

  // Get maintenance schedule
  Future<List<Map<String, dynamic>>> getMaintenanceSchedule() async {
    try {
      final response = await _supabase
        .from('vehicle_maintenance')
        .select('''
          *,
          vehicles (
            vehicle_number,
            type
          )
        ''')
        .gte('due_date', DateTime.now().toIso8601String())
        .order('due_date')
        .limit(50);

      return response;
    } catch (e) {
      debugPrint('Error getting maintenance schedule: $e');
      return [];
    }
  }

  // Stop fleet monitoring
  void stopFleetMonitoring() {
    _statusUpdateTimer?.cancel();
    _analyticsUpdateTimer?.cancel();
    _statusUpdateTimer = null;
    _analyticsUpdateTimer = null;
  }

  // Cleanup
  void dispose() {
    stopFleetMonitoring();
    _fleetStatusController.close();
    _analyticsController.close();
    _alertsController.close();
  }
}
