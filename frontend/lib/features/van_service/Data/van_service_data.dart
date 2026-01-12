import 'package:flutter/material.dart';

enum TripType {
  oneWay,
  roundTrip,
}

class VanRoute {
  final String fromCity;
  final String toCity;
  final String routeName;

  const VanRoute({
    required this.fromCity,
    required this.toCity,
    required this.routeName,
  });

  String get displayName => '$fromCity → $toCity';
}

class VanServiceData {
  TripType selectedTripType = TripType.oneWay;
  String? selectedFromCity;
  String? selectedToCity;
  DateTime? departureDate;
  DateTime? returnDate;

  // Available cities - Coastal Balochistan route
  static const List<String> availableCities = [
    'Karachi',
    'Turbat',
    'Gwadar',
  ];

  // Get available routes based on selected cities
  List<VanRoute> getAvailableRoutes() {
    if (selectedFromCity == null || selectedToCity == null) return [];

    return [
      VanRoute(
        fromCity: selectedFromCity!,
        toCity: selectedToCity!,
        routeName: '$selectedFromCity to $selectedToCity',
      ),
    ];
  }

  bool get isValidForSearch {
    if (selectedFromCity == null || selectedToCity == null || departureDate == null) {
      return false;
    }
    if (selectedTripType == TripType.roundTrip && returnDate == null) {
      return false;
    }
    return true;
  }

  void reset() {
    selectedTripType = TripType.oneWay;
    selectedFromCity = null;
    selectedToCity = null;
    departureDate = null;
    returnDate = null;
  }
}
