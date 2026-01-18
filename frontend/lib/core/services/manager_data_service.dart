import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../../screens/manager/services/service_model.dart';
import '../../core/models/schedule.dart';
import '../../core/models/vehicle.dart';

/// Centralized data service for manager screens to ensure data consistency
/// across services, schedules, and vehicles screens
class ManagerDataService extends ChangeNotifier {
  // Singleton pattern
  static final ManagerDataService _instance = ManagerDataService._internal();

  factory ManagerDataService() {
    return _instance;
  }

  ManagerDataService._internal();
  final ApiService _apiService = ApiService();

  // Cached data
  List<Service> _services = [];
  List<Schedule> _schedules = [];
  List<dynamic> _vehicles = [];

  // Loading states
  bool _isLoadingServices = false;
  bool _isLoadingSchedules = false;
  bool _isLoadingVehicles = false;

  // Getters
  List<Service> get services => _services;
  List<Schedule> get schedules => _schedules;
  List<dynamic> get vehicles => _vehicles;

  bool get isLoadingServices => _isLoadingServices;
  bool get isLoadingSchedules => _isLoadingSchedules;
  bool get isLoadingVehicles => _isLoadingVehicles;

  bool get isLoadingAny =>
      _isLoadingServices || _isLoadingSchedules || _isLoadingVehicles;

  /// Load all manager data with consistent joins
  Future<void> loadAllData() async {
    await Future.wait([loadServices(), loadSchedules(), loadVehicles()]);
  }

  /// Load services data
  Future<void> loadServices() async {
    _isLoadingServices = true;
    notifyListeners();

    try {
      final servicesData = await _apiService.getManagerServices();
      _services = servicesData.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading services: $e');
      _services = [];
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  /// Load schedules data with full joins for consistency
  Future<void> loadSchedules() async {
    _isLoadingSchedules = true;
    notifyListeners();

    try {
      final schedulesData = await _apiService.getManagerSchedules();
      _schedules = schedulesData
          .map((json) => Schedule.fromJson(json))
          .toList();
      // Sort by departure time (upcoming first)
      _schedules.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    } catch (e) {
      debugPrint('Error loading schedules: $e');
      _schedules = [];
    } finally {
      _isLoadingSchedules = false;
      notifyListeners();
    }
  }

  /// Load vehicles/services data - now returns services for track vehicles screen
  Future<void> loadVehicles() async {
    _isLoadingVehicles = true;
    notifyListeners();

    try {
      final servicesData = await _apiService.getManagerVehicles();
      // Store services as dynamic maps instead of Vehicle objects
      _vehicles = servicesData as List<dynamic>;
    } catch (e) {
      debugPrint('Error loading services: $e');
      _vehicles = [];
    } finally {
      _isLoadingVehicles = false;
      notifyListeners();
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await loadAllData();
  }

  /// Get consistent vehicle info by ID (ensures same data across screens)
  Vehicle? getVehicleById(String vehicleId) {
    return _vehicles.firstWhere((v) => v.id == vehicleId);
  }

  /// Get consistent driver name for vehicle
  String getDriverNameForVehicle(String? vehicleId) {
    if (vehicleId == null) return 'Unassigned';
    final vehicle = getVehicleById(vehicleId);
    return vehicle?.driverName ?? 'Unassigned';
  }

  /// Get consistent vehicle number/registration
  String getVehicleNumber(String? vehicleId) {
    if (vehicleId == null) return 'Unknown';
    final vehicle = getVehicleById(vehicleId);
    return vehicle?.registrationNumber ?? 'Unknown';
  }

  /// Get service by ID
  Service? getServiceById(String serviceId) {
    return _services.firstWhere((s) => s.id == serviceId);
  }

  /// Update service and refresh related data
  Future<void> updateService(
    String serviceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final updatedService = await _apiService.updateService(serviceId, data);
      final index = _services.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        final oldService = _services[index];
        _services[index] = Service.fromJson(updatedService);

        // If capacity changed, cascade the update to related vehicles and schedules
        if (data.containsKey('capacity') &&
            data['capacity'] != oldService.capacity) {
          await _cascadeCapacityUpdate(serviceId, data['capacity']);
        }

        notifyListeners();

        // Refresh schedules and vehicles as they may reference this service
        await loadSchedules();
        await loadVehicles();
      }
    } catch (e) {
      debugPrint('Error updating service: $e');
      rethrow;
    }
  }

  /// Cascade capacity updates to related vehicles and schedules
  Future<void> _cascadeCapacityUpdate(String serviceId, int newCapacity) async {
    try {
      final user = _apiService.supabase.auth.currentUser;
      if (user == null) return;

      // Update all vehicles for this service
      await _apiService.supabase
          .from('vehicles')
          .update({
            'capacity': newCapacity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('service_id', serviceId)
          .eq('services.manager_id', user.id); // Ensure user owns the service

      // Update all schedules for vehicles of this service
      await _apiService.supabase
          .from('schedules')
          .update({
            'total_seats': newCapacity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vehicles.service_id', serviceId)
          .eq(
            'vehicles.services.manager_id',
            user.id,
          ); // Ensure user owns the service

      debugPrint(
        'Cascaded capacity update: service $serviceId -> $newCapacity seats',
      );
    } catch (e) {
      debugPrint('Error cascading capacity update: $e');
      // Don't rethrow - service update succeeded, cascade is secondary
    }
  }

  /// Create vehicle and add to cache
  Future<Vehicle> createVehicle(Map<String, dynamic> vehicleData) async {
    try {
      final createdVehicle = await _apiService.createVehicle(vehicleData);
      final newVehicle = Vehicle.fromJson(createdVehicle);
      _vehicles.add(newVehicle);

      // Sort vehicles after adding new one
      _vehicles.sort((a, b) {
        if (a.status != b.status) {
          return a.status.index.compareTo(b.status.index);
        }
        return a.registrationNumber.compareTo(b.registrationNumber);
      });

      notifyListeners();
      return newVehicle;
    } catch (e) {
      debugPrint('Error creating vehicle: $e');
      rethrow;
    }
  }

  /// Update vehicle and refresh related data
  Future<void> updateVehicle(
    String vehicleId,
    Map<String, dynamic> data,
  ) async {
    try {
      final updatedVehicle = await _apiService.updateVehicle(vehicleId, data);
      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _vehicles[index] = Vehicle.fromJson(updatedVehicle);
        notifyListeners();

        // Refresh schedules as vehicle changes may affect schedule data
        await loadSchedules();
      }
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
      rethrow;
    }
  }

  /// Update schedule and refresh related data
  Future<void> updateSchedule(
    String scheduleId,
    Map<String, dynamic> data,
  ) async {
    try {
      final updatedSchedule = await _apiService.updateSchedule(
        scheduleId,
        data,
      );
      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        _schedules[index] = Schedule.fromJson(updatedSchedule);
        notifyListeners();

        // Refresh vehicles as schedule changes may affect vehicle assignments
        await loadVehicles();
      }
    } catch (e) {
      debugPrint('Error updating schedule: $e');
      rethrow;
    }
  }

  /// Helper methods for UI consistency
  List<Schedule> getUpcomingSchedules() {
    return _schedules.where((s) => s.isUpcoming).toList();
  }

  List<Schedule> getActiveSchedules() {
    return _schedules.where((s) => s.isActive).toList();
  }

  List<Service> getActiveServices() {
    return _services.where((s) => s.status == ServiceStatus.active).toList();
  }

  // Note: These methods now work with service data instead of vehicles
  List<dynamic> getActiveServiceData() {
    return _vehicles.where((s) => s['status'] == 'active').toList();
  }

  List<dynamic> getServiceDataInUse() {
    // Services don't have "in use" status, return empty list
    return [];
  }
}
