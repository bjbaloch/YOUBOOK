class AppConstants {
  // API Constants
  static const String apiBaseUrl = 'https://semimoderate-gerard-treasonable.ngrok-free.dev/api/v1';

  // Hive Box Names
  static const String offlineBox = 'offline_data';
  static const String ticketsBox = 'tickets';

  // User Roles
  static const String rolePassenger = 'passenger';
  static const String roleManager = 'manager';
  static const String roleDriver = 'driver';

  // Service Types
  static const String serviceTransport = 'transport';
  static const String serviceAccommodation = 'accommodation';
  static const String serviceRental = 'rental';

  // Notification Channels
  static const String bookingChannel = 'booking_notifications';
  static const String trackingChannel = 'tracking_notifications';

  // Realtime Subscriptions
  static const String locationChannel = 'location_updates';
  static const String bookingUpdatesChannel = 'booking_updates';

  // Background Service
  static const String locationServiceId = 'location_service';

  // Payment
  static const double platformFee = 0.05; // 5% platform fee

  // Booking
  static const int seatLockDurationMinutes = 5;
  static const int maxSeatsPerBooking = 5;

  // Map Settings
  static const double defaultZoomLevel = 15.0;
  static const double trafficZoomThreshold = 12.0;
}
