part of 'manager_services_screen.dart';

class ManagerServicesData {
  final ManagerDataService _dataService;

  ManagerServicesData(this._dataService);

  List<Service> get services => _dataService.services;
  bool get isLoading => _dataService.isLoadingServices;

  Future<void> loadServices() async {
    await _dataService.loadServices();
  }

  void addService(Service service) {
    // Services are managed centrally, this method kept for compatibility
    // Actual addition happens through API calls in the service
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    await _dataService.updateService(serviceId, data);
  }

  void deleteService(String serviceId) {
    // Services are managed centrally, deletion happens through API
  }

  Future<void> refreshServices() async {
    await _dataService.loadServices();
  }

  List<Service> getActiveServices() {
    return _dataService.getActiveServices();
  }

  List<Service> getPausedServices() {
    return services.where((s) =>
        s.status == ServiceStatus.inactive ||
        s.status == ServiceStatus.maintenance ||
        s.status == ServiceStatus.suspended).toList();
  }

  List<Service> getServicesByType(ServiceType type) {
    return services.where((s) => s.type == type).toList();
  }

  double getTotalRevenue() {
    return services
        .where((s) => s.status == ServiceStatus.active)
        .fold<double>(0.0, (sum, s) => sum + s.basePrice);
  }
}
