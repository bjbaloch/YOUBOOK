import 'package:flutter/material.dart';
import '../../../screens/passenger/Home/UI/passenger_home_ui.dart';
import '../../../screens/passenger/Home/Data/passenger_home_data.dart';
import '../UI/booking_details_ui.dart';

class MyBookingLogic {
  static Future<bool> handleBackPress(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PassengerHomeUI(data: PassengerHomeData())),
    );
    return false; // prevent default back behavior
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PassengerHomeUI(data: PassengerHomeData())),
    );
  }

  static void navigateToBookingDetails(BuildContext context, String bookingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsUI(bookingId: bookingId),
      ),
    );
  }
}
