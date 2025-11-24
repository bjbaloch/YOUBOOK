import 'package:flutter/foundation.dart';

class LocationProvider with ChangeNotifier {
  bool _isTrackingLocation = false;

  bool get isTrackingLocation => _isTrackingLocation;

  Future<void> startTracking() async {
    _isTrackingLocation = true;
    notifyListeners();
    // Start location tracking logic would go here
  }

  Future<void> stopTracking() async {
    _isTrackingLocation = false;
    notifyListeners();
    // Stop location tracking logic would go here
  }
}
