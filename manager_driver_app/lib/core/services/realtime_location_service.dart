import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/location_data.dart';

class RealtimeLocationService {
  static final RealtimeLocationService _instance = RealtimeLocationService._internal();
  factory RealtimeLocationService() => _instance;
  RealtimeLocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _locationUpdateTimer;

  bool _isTracking = false;
  String? _currentVehicleId;
  String? _currentDriverId;

  static const int LOCATION_UPDATE_INTERVAL = 30;
  static const double LOCATION_ACCURACY = 10.0;
  static const int BATCH_SIZE = 5;

  final List<LocationData> _locationBuffer = [];
  Timer? _batchTimer;

  final StreamController<LocationData> _currentLocationController = StreamController<LocationData>.broadcast();
  final StreamController<Map<String, dynamic>> _vehicleLocationsController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<LocationData> get currentLocationStream => _currentLocationController.stream;
  Stream<Map<String, dynamic>> get vehicleLocationsStream => _vehicleLocationsController.stream;

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
    // TODO: Restore Supabase initialization when connecting backend
    final locationService = RealtimeLocationService();
    await locationService._startBackgroundLocationTracking();

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

  Future<void> startDriverTracking({
    required String vehicleId,
    required String driverId,
  }) async {
    _currentVehicleId = vehicleId;
    _currentDriverId = driverId;
    _isTracking = true;

    final service = FlutterBackgroundService();
    await service.startService();
    service.invoke('updateVehicle', {'vehicleId': vehicleId, 'driverId': driverId});

    await _startRealtimeLocationUpdates();
    _startBatchProcessing();
  }

  Future<void> stopDriverTracking() async {
    _isTracking = false;
    _currentVehicleId = null;
    _currentDriverId = null;

    final service = FlutterBackgroundService();
    service.invoke('stop');

    await _stopLocationTracking();
    _stopBatchProcessing();
  }

  Future<void> _startBackgroundLocationTracking() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: LOCATION_ACCURACY.toInt(),
      timeLimit: Duration(seconds: LOCATION_UPDATE_INTERVAL),
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onLocationUpdate);
  }

  Future<void> _stopBackgroundLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

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

    _currentLocationController.add(locationData);
    _locationBuffer.add(locationData);

    if (_locationBuffer.length >= BATCH_SIZE) {
      _processLocationBatch();
    }
  }

  Future<void> _startRealtimeLocationUpdates() async {
    // TODO: Restore Supabase realtime channel when connecting backend
  }

  void _startBatchProcessing() {
    _batchTimer = Timer.periodic(
      const Duration(seconds: LOCATION_UPDATE_INTERVAL),
      (_) => _processLocationBatch(),
    );
  }

  void _stopBatchProcessing() {
    _batchTimer?.cancel();
    _batchTimer = null;
    if (_locationBuffer.isNotEmpty) {
      _processLocationBatch();
    }
  }

  Future<void> _processLocationBatch() async {
    if (_locationBuffer.isEmpty) return;
    // TODO: Restore Supabase batch insert when connecting backend
    debugPrint('Location batch skipped in UI-only mode: ${_locationBuffer.length} updates');
    _locationBuffer.clear();
  }

  void _updateVehicleInfo(String? vehicleId, String? driverId) {
    _currentVehicleId = vehicleId;
    _currentDriverId = driverId;
  }

  Future<void> _stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _locationUpdateTimer?.cancel();

    _positionSubscription = null;
    _locationUpdateTimer = null;
  }

  Stream<LocationData?> watchVehicleLocation(String vehicleId) {
    return Stream.periodic(const Duration(seconds: 10), (_) async {
      return await getLatestVehicleLocation(vehicleId);
    }).asyncMap((future) => future);
  }

  Stream<List<Map<String, dynamic>>> watchAllVehicleLocations() {
    // TODO: Restore Supabase stream when connecting backend
    return const Stream.empty();
  }

  Future<LocationData?> getLatestVehicleLocation(String vehicleId) async {
    // TODO: Restore Supabase query when connecting backend
    return null;
  }

  Future<Duration?> calculateETA({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    double averageSpeed = 40.0,
  }) async {
    try {
      const double earthRadius = 6371;
      final double dLat = _degreesToRadians(endLat - startLat);
      final double dLng = _degreesToRadians(endLng - startLng);
      final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(_degreesToRadians(startLat)) *
          math.cos(_degreesToRadians(endLat)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
      final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      final double distance = earthRadius * c;
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

  void dispose() {
    _positionSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    _batchTimer?.cancel();
    _currentLocationController.close();
    _vehicleLocationsController.close();
  }
}
