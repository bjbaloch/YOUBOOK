import 'package:flutter/material.dart';
import '../Data/bus_service_data.dart';
import '../UI/bus_service_ui.dart';
import '../UI/available_buses_ui.dart';
import '../../../screens/passenger/Home/UI/passenger_home_ui.dart';
import '../../../screens/passenger/Home/Data/passenger_home_data.dart';

class BusServiceLogic {
  static PageRouteBuilder smoothTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  static Future<bool> handleBackPress(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      smoothTransition(const PassengerHomeUI(data: PassengerHomeData())),
    );
    return false;
  }

  static void navigateToBusService(BuildContext context) {
    Navigator.push(
      context,
      smoothTransition(const BusServiceUI()),
    );
  }

  static void navigateToAvailableBuses(
    BuildContext context,
    BusServiceData searchData,
  ) {
    Navigator.push(
      context,
      smoothTransition(AvailableBusesUI(searchData: searchData)),
    );
  }

  static void navigateBackToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      smoothTransition(const PassengerHomeUI(data: PassengerHomeData())),
    );
  }

  static void navigateBackToBusService(BuildContext context) {
    Navigator.pop(context);
  }

  static Future<DateTime?> selectDate(
    BuildContext context,
    DateTime initialDate,
    DateTime firstDate,
    DateTime lastDate,
  ) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String getTripTypeDisplayName(TripType tripType) {
    switch (tripType) {
      case TripType.oneWay:
        return 'One Way';
      case TripType.roundTrip:
        return 'Round Trip';
    }
  }
}
