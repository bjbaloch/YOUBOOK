import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

enum TripType { oneWay, roundTrip }

class RouteModel {
  final String id;
  final String name;
  final String serviceType;
  final Map<String, dynamic> startLocation;
  final Map<String, dynamic> endLocation;
  final double? distanceKm;
  final int? estimatedDurationMinutes;
  final bool isActive;

  const RouteModel({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.startLocation,
    required this.endLocation,
    this.distanceKm,
    this.estimatedDurationMinutes,
    this.isActive = true,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      serviceType: json['service_type'] ?? 'van',
      startLocation: json['start_location'] ?? {},
      endLocation: json['end_location'] ?? {},
      distanceKm: json['distance_km']?.toDouble(),
      estimatedDurationMinutes: json['estimated_duration_minutes'],
      isActive: json['is_active'] ?? true,
    );
  }

  String get fromCity =>
      startLocation['city'] ?? startLocation['address'] ?? 'Unknown';
  String get toCity =>
      endLocation['city'] ?? endLocation['address'] ?? 'Unknown';
  String get displayName => name.isNotEmpty ? name : '$fromCity → $toCity';
}

class VanServiceData {
  TripType selectedTripType = TripType.oneWay;
  RouteModel? selectedRoute;
  String? selectedFromLocation;
  String? selectedToLocation;
  DateTime? departureDate;
  DateTime? returnDate;

  // Dynamic routes fetched from database
  static List<RouteModel> _availableRoutes = [];
  static bool _routesLoaded = false;

  // Get available routes from database (van routes only)
  static Future<List<RouteModel>> getAvailableRoutes() async {
    if (!_routesLoaded) {
      try {
        final apiService = ApiService();
        final routesData = await apiService.getRoutes(serviceType: 'van');
        _availableRoutes = routesData
            .map((json) => RouteModel.fromJson(json))
            .toList();
        _routesLoaded = true;
      } catch (e) {
        debugPrint('Error loading van routes: $e');
        // No fallback routes - only show manager-added routes
        _availableRoutes = [];
        _routesLoaded = true;
      }
    }
    return _availableRoutes;
  }

  // Refresh routes (useful when new routes are added)
  static void refreshRoutes() {
    _routesLoaded = false;
    _availableRoutes.clear();
  }

  bool get isValidForSearch {
    if (selectedFromLocation == null ||
        selectedToLocation == null ||
        departureDate == null) {
      return false;
    }
    if (selectedTripType == TripType.roundTrip && returnDate == null) {
      return false;
    }
    return true;
  }

  void reset() {
    selectedTripType = TripType.oneWay;
    selectedRoute = null;
    selectedFromLocation = null;
    selectedToLocation = null;
    departureDate = null;
    returnDate = null;
  }
}
