part of 'manager_drivers_screen.dart';

class ManagerDriversData {
  List<Driver> drivers = [];
  bool isLoading = false;

  Future<void> loadDrivers() async {
    isLoading = true;
    // TODO: Restore API call when connecting backend
    drivers = [];
    isLoading = false;
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