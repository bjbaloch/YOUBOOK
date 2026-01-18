part of 'manager_drivers_screen.dart';

class ManagerDriversData {
  List<Driver> drivers = [];
  bool isLoading = false;
  final ApiService _apiService = ApiService();

  ApiService get apiService => _apiService;

  Future<void> loadDrivers() async {
    isLoading = true;
    try {
      final driversData = await _apiService.getManagerDrivers();
      drivers = driversData.map((json) => Driver.fromJson(json)).toList();
      // Sort by status (active first) then by name
      drivers.sort((a, b) {
        if (a.status != b.status) {
          return a.status.index.compareTo(b.status.index);
        }
        return a.fullName.compareTo(b.fullName);
      });
    } catch (e) {
      // On error, keep empty list
      drivers = [];
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  List<Driver> getActiveDrivers() {
    return drivers
        .where(
          (d) =>
              d.status == DriverStatus.idle ||
              d.status == DriverStatus.assigned,
        )
        .toList();
  }

  List<Driver> getAvailableDrivers() {
    return drivers.where((d) => d.isAvailable).toList();
  }

  List<Driver> getOnDutyDrivers() {
    return drivers.where((d) => d.isOnDuty).toList();
  }

  List<Driver> getDriversByStatus(DriverStatus status) {
    return drivers.where((d) => d.status == status).toList();
  }
}
