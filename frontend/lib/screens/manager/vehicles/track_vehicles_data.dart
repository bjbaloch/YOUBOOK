part of 'track_vehicles_screen.dart';

class TrackVehiclesData {
  List<Vehicle> vehicles = [];
  bool isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> loadVehicles() async {
    isLoading = true;
    try {
      final vehiclesData = await _apiService.getManagerVehicles();
      vehicles = vehiclesData.map((json) => Vehicle.fromJson(json)).toList();
      // Sort by status (active first) then by registration number
      vehicles.sort((a, b) {
        if (a.status != b.status) {
          return a.status.index.compareTo(b.status.index);
        }
        return a.registrationNumber.compareTo(b.registrationNumber);
      });
    } catch (e) {
      vehicles = [];
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  List<Vehicle> getActiveVehicles() {
    return vehicles.where((v) => v.status == VehicleStatus.active).toList();
  }

  List<Vehicle> getVehiclesNeedingMaintenance() {
    return vehicles.where((v) => v.needsMaintenance).toList();
  }

  List<Vehicle> getVehiclesInUse() {
    return vehicles.where((v) => v.isInUse).toList();
  }

  List<Vehicle> getVehiclesByStatus(VehicleStatus status) {
    return vehicles.where((v) => v.status == status).toList();
  }
}
