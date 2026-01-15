part of 'manager_services_screen.dart';

class ManagerServicesData {
  List<Service> services = [];
  bool isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> loadServices() async {
    isLoading = true;
    try {
      final servicesData = await _apiService.getManagerServices();
      services = servicesData.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      // On error, keep empty list
      services = [];
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  void addService(Service service) {
    services.add(service);
  }

  void updateService(Service updatedService) {
    final index = services.indexWhere((s) => s.id == updatedService.id);
    if (index != -1) {
      services[index] = updatedService;
      // Trigger a UI update if needed
    }
  }

  void deleteService(String serviceId) {
    services.removeWhere((s) => s.id == serviceId);
  }

  Future<void> refreshServices() async {
    await loadServices();
  }

  List<Service> getActiveServices() {
    return services.where((s) => s.status == ServiceStatus.active).toList();
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
