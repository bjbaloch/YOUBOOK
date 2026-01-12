part of 'manager_services_screen.dart';

enum ServiceType {
  standard,
  premium,
  express,
  luxury,
}

enum ServiceStatus {
  active,
  inactive,
  maintenance,
  suspended,
}

class Service {
  final String id;
  final String name;
  final String description;
  final ServiceType type;
  ServiceStatus status;
  final double basePrice;
  final int capacity;
  final String route;
  final List<String> features;
  final DateTime createdAt;
  DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.basePrice,
    required this.capacity,
    required this.route,
    required this.features,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.create({
    required String name,
    required String description,
    required ServiceType type,
    required double basePrice,
    required int capacity,
    required String route,
    required List<String> features,
  }) {
    final now = DateTime.now();
    return Service(
      id: 'service_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      type: type,
      status: ServiceStatus.active,
      basePrice: basePrice,
      capacity: capacity,
      route: route,
      features: features,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class ManagerServicesData {
  List<Service> services = [];
  bool isLoading = false;

  Future<void> loadServices() async {
    isLoading = true;
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Sample services
    services = [
      Service.create(
        name: 'Islamabad to Lahore Standard',
        description: 'Standard van service between Islamabad and Lahore',
        type: ServiceType.standard,
        basePrice: 2500.0,
        capacity: 12,
        route: 'Islamabad → Lahore',
        features: ['AC', 'WiFi', 'Refreshments'],
      ),
      Service.create(
        name: 'Rawalpindi to Islamabad Express',
        description: 'Express service with premium amenities',
        type: ServiceType.express,
        basePrice: 1800.0,
        capacity: 8,
        route: 'Rawalpindi → Islamabad',
        features: ['AC', 'WiFi', 'Premium Seats', 'Snacks'],
      ),
      Service.create(
        name: 'Lahore to Karachi Premium',
        description: 'Premium long-distance service',
        type: ServiceType.premium,
        basePrice: 8500.0,
        capacity: 10,
        route: 'Lahore → Karachi',
        features: ['AC', 'WiFi', 'Meals', 'Entertainment', 'Reclining Seats'],
      ),
      Service.create(
        name: 'Peshawar to Islamabad Standard',
        description: 'Regular service for Peshawar route',
        type: ServiceType.standard,
        basePrice: 2200.0,
        capacity: 14,
        route: 'Peshawar → Islamabad',
        features: ['AC', 'WiFi'],
      ),
    ];

    isLoading = false;
  }

  void addService(Service service) {
    services.add(service);
  }

  void updateService(Service updatedService) {
    final index = services.indexWhere((s) => s.id == updatedService.id);
    if (index != -1) {
      services[index] = updatedService;
    }
  }

  void deleteService(String serviceId) {
    services.removeWhere((s) => s.id == serviceId);
  }

  List<Service> getActiveServices() {
    return services.where((s) => s.status == ServiceStatus.active).toList();
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
