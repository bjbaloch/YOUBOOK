import 'package:flutter/foundation.dart';
import '../../screens/manager/services/service_model.dart';
import '../../core/models/schedule.dart';
import '../../core/models/vehicle.dart';

/// Centralized data service for manager screens to ensure data consistency
/// across services, schedules, and vehicles screens
class ManagerDataService extends ChangeNotifier {
  static final ManagerDataService _instance = ManagerDataService._internal();
  factory ManagerDataService() => _instance;
  ManagerDataService._internal();

  List<Service> _services = [];
  List<Schedule> _schedules = [];
  List<dynamic> _vehicles = [];

  bool _isLoadingServices = false;
  bool _isLoadingSchedules = false;
  bool _isLoadingVehicles = false;

  List<Service> get services => _services;
  List<Schedule> get schedules => _schedules;
  List<dynamic> get vehicles => _vehicles;

  bool get isLoadingServices => _isLoadingServices;
  bool get isLoadingSchedules => _isLoadingSchedules;
  bool get isLoadingVehicles => _isLoadingVehicles;
  bool get isLoadingAny => _isLoadingServices || _isLoadingSchedules || _isLoadingVehicles;

  Future<void> loadAllData() async {
    await Future.wait([loadServices(), loadSchedules(), loadVehicles()]);
  }

  Future<void> loadServices() async {
    _isLoadingServices = true;
    notifyListeners();
    // TODO: Restore API call when connecting backend
    _services = [];
    _isLoadingServices = false;
    notifyListeners();
  }

  Future<void> loadSchedules() async {
    _isLoadingSchedules = true;
    notifyListeners();
    // TODO: Restore API call when connecting backend
    _schedules = [];
    _isLoadingSchedules = false;
    notifyListeners();
  }

  Future<void> loadVehicles() async {
    _isLoadingVehicles = true;
    notifyListeners();
    // TODO: Restore API call when connecting backend
    _vehicles = [];
    _isLoadingVehicles = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await loadAllData();
  }

  Vehicle? getVehicleById(String vehicleId) {
    return _vehicles.firstWhere((v) => v.id == vehicleId);
  }

  String getDriverNameForVehicle(String? vehicleId) {
    if (vehicleId == null) return 'Unassigned';
    final vehicle = getVehicleById(vehicleId);
    return vehicle?.driverName ?? 'Unassigned';
  }

  String getVehicleNumber(String? vehicleId) {
    if (vehicleId == null) return 'Unknown';
    final vehicle = getVehicleById(vehicleId);
    return vehicle?.registrationNumber ?? 'Unknown';
  }

  Service? getServiceById(String serviceId) {
    return _services.firstWhere((s) => s.id == serviceId);
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    // TODO: Restore API call when connecting backend
    debugPrint('updateService skipped in UI-only mode');
    notifyListeners();
  }

  Future<void> _cascadeCapacityUpdate(String serviceId, int newCapacity) async {
    // TODO: Restore when connecting backend
    debugPrint('Cascade capacity update skipped in UI-only mode');
  }

  Future<Vehicle> createVehicle(Map<String, dynamic> vehicleData) async {
    // TODO: Restore API call when connecting backend
    throw UnimplementedError('createVehicle not available in UI-only mode');
  }

  Future<void> updateVehicle(String vehicleId, Map<String, dynamic> data) async {
    // TODO: Restore API call when connecting backend
    debugPrint('updateVehicle skipped in UI-only mode');
    notifyListeners();
  }

  Future<void> updateSchedule(String scheduleId, Map<String, dynamic> data) async {
    // TODO: Restore API call when connecting backend
    debugPrint('updateSchedule skipped in UI-only mode');
    notifyListeners();
  }

  List<Schedule> getUpcomingSchedules() {
    return _schedules.where((s) => s.isUpcoming).toList();
  }

  List<Schedule> getActiveSchedules() {
    return _schedules.where((s) => s.isActive).toList();
  }

  List<Service> getActiveServices() {
    return _services.where((s) => s.status == ServiceStatus.active).toList();
  }

  List<dynamic> getActiveServiceData() {
    return _vehicles.where((s) => s['status'] == 'active').toList();
  }

  List<dynamic> getServiceDataInUse() {
    return [];
  }
}
