import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/location_data.dart';

class RealtimeLocationService {
  static final RealtimeLocationService _instance = RealtimeLocationService._internal();
  factory RealtimeLocationService() => _instance;
  RealtimeLocationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<Position>? _positionSubscription;
  RealtimeChannel? _locationChannel;
  Timer? _locationUpdateTimer;

  // Location tracking state
  bool _isTracking = false;
  String? _currentVehicleId;
  String? _currentDriverId;

  // Location settings
  static const int LOCATION_UPDATE_INTERVAL = 30; // seconds
  static const double LOCATION_ACCURACY = 10.0; // meters
  static const int BATCH_SIZE = 5; // Send location updates in batches

  // Location buffer for batch processing
  final List<LocationData> _locationBuffer = [];
  Timer? _batchTimer;

  // Streams for UI updates
  final StreamController<LocationData> _currentLocationController = StreamController<LocationData>.broadcast();
  final StreamController<Map<String, dynamic>> _vehicleLocationsController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<LocationData> get currentLocationStream => _currentLocationController.stream;
  Stream<Map<String, dynamic>> get vehicleLocationsStream => _vehicleLocationsController.stream;

  // Initialize background service
  Future<void> initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_tracking',
        initialNotificationTitle: 'YOUBOOK Location Tracking',
        initialNotificationContent: 'Tracking your location for live updates',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Initialize Supabase in background
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );

    final locationService = RealtimeLocationService();

    // Start location tracking
    await locationService._startBackgroundLocationTracking();

    // Handle service commands
    service.on('stop').listen((event) {
      locationService._stopBackgroundLocationTracking();
      service.stopSelf();
    });

    service.on('updateVehicle').listen((event) {
      final vehicleId = event?['vehicleId'] as String?;
      final driverId = event?['driverId'] as String?;
      locationService._updateVehicleInfo(vehicleId, driverId);
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  // Start location tracking for driver
  Future<void> startDriverTracking({
    required String vehicleId,
    required String driverId,
  }) async {
    _currentVehicleId = vehicleId;
    _currentDriverId = driverId;
    _isTracking = true;

    // Start background service
    final service = FlutterBackgroundService();
    await service.startService();

    // Send vehicle info to background service
    service.invoke('updateVehicle', {
      'vehicleId': vehicleId,
      'driverId': driverId,
    });

    // Start real-time location updates
    await _startRealtimeLocationUpdates();

    // Start batch processing
    _startBatchProcessing();
  }

  // Stop location tracking
  Future<void> stopDriverTracking() async {
    _isTracking = false;
    _currentVehicleId = null;
    _currentDriverId = null;

    // Stop background service
    final service = FlutterBackgroundService();
    service.invoke('stop');

    // Stop subscriptions and timers
    await _stopLocationTracking();
    _stopBatchProcessing();
  }

  // Start background location tracking
  Future<void> _startBackgroundLocationTracking() async {
    // Request location permissions
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    // Configure location settings for battery efficiency
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: LOCATION_ACCURACY.toInt(),
      timeLimit: Duration(seconds: LOCATION_UPDATE_INTERVAL),
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onLocationUpdate);
  }

  // Stop background location tracking
  Future<void> _stopBackgroundLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  // Handle location updates
  void _onLocationUpdate(Position position) {
    if (!_isTracking || _currentVehicleId == null) return;

    final locationData = LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
      timestamp: DateTime.now(),
      vehicleId: _currentVehicleId!,
      driverId: _currentDriverId!,
    );

    // Add to current location stream
    _currentLocationController.add(locationData);

    // Add to buffer for batch processing
    _locationBuffer.add(locationData);

    // Process batch if buffer is full
    if (_locationBuffer.length >= BATCH_SIZE) {
      _processLocationBatch();
    }
  }

  // Start real-time location updates via Supabase
  Future<void> _startRealtimeLocationUpdates() async {
    _locationChannel = _supabase.channel('vehicle_location_${_currentVehicleId}');

    // Subscribe to location updates
    _locationChannel!.subscribe();
  }

  // Handle real-time location updates from other vehicles
  void _onRealtimeLocationUpdate(dynamic payload) {
    final data = payload as Map<String, dynamic>;
    _vehicleLocationsController.add(data);
  }

  // Start batch processing timer
  void _startBatchProcessing() {
    _batchTimer = Timer.periodic(
      const Duration(seconds: LOCATION_UPDATE_INTERVAL),
      (_) => _processLocationBatch(),
    );
  }

  // Stop batch processing
  void _stopBatchProcessing() {
    _batchTimer?.cancel();
    _batchTimer = null;
    // Process remaining locations
    if (_locationBuffer.isNotEmpty) {
      _processLocationBatch();
    }
  }

  // Process batch of location updates
  Future<void> _processLocationBatch() async {
    if (_locationBuffer.isEmpty) return;

    try {
      // Prepare batch data
      final batchData = _locationBuffer.map((location) => {
        'vehicle_id': location.vehicleId,
        'driver_id': location.driverId,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy': location.accuracy,
        'speed': location.speed,
        'heading': location.heading,
        'timestamp': location.timestamp.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      // Insert batch into Supabase
      await _supabase.from('vehicle_locations').insert(batchData);

      // Broadcast location update
      await _locationChannel?.sendBroadcastMessage(
        event: 'location_update',
        payload: {
          'vehicleId': _currentVehicleId,
          'driverId': _currentDriverId,
          'latitude': _locationBuffer.last.latitude,
          'longitude': _locationBuffer.last.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Clear buffer
      _locationBuffer.clear();

      debugPrint('Location batch processed: ${batchData.length} updates');
    } catch (e) {
      debugPrint('Error processing location batch: $e');
    }
  }

  // Update vehicle information
  void _updateVehicleInfo(String? vehicleId, String? driverId) {
    _currentVehicleId = vehicleId;
    _currentDriverId = driverId;
  }

  // Stop location tracking
  Future<void> _stopLocationTracking() async {
    await _positionSubscription?.cancel();
    await _locationChannel?.unsubscribe();
    _locationUpdateTimer?.cancel();

    _positionSubscription = null;
    _locationChannel = null;
    _locationUpdateTimer = null;
  }

  // Watch vehicle location (for passengers)
  Stream<LocationData?> watchVehicleLocation(String vehicleId) {
    // Create a stream that periodically fetches the latest location
    return Stream.periodic(const Duration(seconds: 10), (_) async {
      return await getLatestVehicleLocation(vehicleId);
    }).asyncMap((future) => future);
  }

  // Get vehicle locations (for managers)
  Stream<List<Map<String, dynamic>>> watchAllVehicleLocations() {
    return _supabase
      .from('vehicle_locations')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .limit(100)
      .map((data) => data as List<Map<String, dynamic>>);
  }

  // Get latest vehicle location
  Future<LocationData?> getLatestVehicleLocation(String vehicleId) async {
    try {
      final response = await _supabase
        .from('vehicle_locations')
        .select()
        .eq('vehicle_id', vehicleId)
        .order('created_at', ascending: false)
        .limit(1)
        .single();

      if (response.isEmpty) return null;

      return LocationData(
        latitude: response['latitude'] as double,
        longitude: response['longitude'] as double,
        accuracy: response['accuracy'] as double? ?? 10.0,
        speed: response['speed'] as double? ?? 0.0,
        heading: response['heading'] as double? ?? 0.0,
        timestamp: DateTime.parse(response['timestamp'] as String),
        vehicleId: response['vehicle_id'] as String,
        driverId: response['driver_id'] as String,
      );
    } catch (e) {
      debugPrint('Error getting latest location: $e');
      return null;
    }
  }

  // Calculate ETA between two points
  Future<Duration?> calculateETA({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    double averageSpeed = 40.0, // km/h
  }) async {
    try {
      // Calculate distance using haversine formula
      const double earthRadius = 6371; // km

      final double dLat = _degreesToRadians(endLat - startLat);
      final double dLng = _degreesToRadians(endLng - startLng);

      final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(_degreesToRadians(startLat)) *
          math.cos(_degreesToRadians(endLat)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);

      final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      final double distance = earthRadius * c; // km

      // Calculate time at average speed
      final double timeHours = distance / averageSpeed;
      final int timeMinutes = (timeHours * 60).round();

      return Duration(minutes: timeMinutes);
    } catch (e) {
      debugPrint('Error calculating ETA: $e');
      return null;
    }
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  // Cleanup
  void dispose() {
    _positionSubscription?.cancel();
    _locationChannel?.unsubscribe();
    _locationUpdateTimer?.cancel();
    _batchTimer?.cancel();
    _currentLocationController.close();
    _vehicleLocationsController.close();
  }
}
