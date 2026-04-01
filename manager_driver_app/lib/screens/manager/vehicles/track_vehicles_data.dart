part of 'track_vehicles_screen.dart';

class TrackVehiclesData {
  final ManagerDataService _dataService;

  TrackVehiclesData(this._dataService);

  List<dynamic> get vehicles => _dataService.vehicles;
  bool get isLoading => _dataService.isLoadingVehicles;

  Future<void> loadVehicles() async {
    await _dataService.loadVehicles();
  }

  // Note: These methods are not used since we now display services instead of vehicles
  List<dynamic> getActiveServices() {
    return vehicles.where((s) => s['status'] == 'active').toList();
  }

  List<dynamic> getServicesByType(String type) {
    return vehicles.where((s) => s['type'] == type).toList();
  }
}
