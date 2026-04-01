part of 'driver_home_screen.dart';

class DriverData {
  TripManifest? manifest;
  bool isOnline = true;
  bool isTripActive = false;
  DateTime? tripStartTime;
  DateTime? tripEndTime;

  int get totalPassengers => manifest?.passengers.length ?? 0;
  int get checkedInCount => manifest?.passengers.where((p) => p.isCheckedIn).length ?? 0;
  bool get hasPendingSync => manifest?.passengers.any((p) => p.pendingSync) ?? false;

  Future<void> loadManifest() async {
    try {
      final box = await Hive.openBox(AppConstants.offlineBox);
      final manifestData = box.get('driver_manifest');

      if (manifestData != null) {
        manifest = TripManifest.fromJson(manifestData);
      }
    } catch (e) {
      debugPrint('Error loading manifest: $e');
    }
  }

  Future<void> saveManifest() async {
    if (manifest != null) {
      try {
        final box = await Hive.openBox(AppConstants.offlineBox);
        await box.put('driver_manifest', manifest!.toJson());
      } catch (e) {
        debugPrint('Error saving manifest: $e');
      }
    }
  }

  Future<void> checkTripStatus() async {
    try {
      final box = await Hive.openBox(AppConstants.offlineBox);
      final tripStatus = box.get('trip_status');

      if (tripStatus != null) {
        isTripActive = tripStatus['isActive'] ?? false;
        if (tripStatus['startTime'] != null) {
          tripStartTime = DateTime.parse(tripStatus['startTime']);
        }
      }
    } catch (e) {
      debugPrint('Error checking trip status: $e');
    }
  }

  Future<void> startTripTracking() async {
    try {
      final box = await Hive.openBox(AppConstants.offlineBox);
      await box.put('trip_status', {
        'isActive': true,
        'startTime': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving trip status: $e');
    }
  }

  Future<void> endTripTracking() async {
    try {
      final box = await Hive.openBox(AppConstants.offlineBox);
      await box.put('trip_status', {
        'isActive': false,
        'startTime': tripStartTime?.toIso8601String(),
        'endTime': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving trip status: $e');
    }
  }

  void checkInPassenger(String passengerId) {
    final passenger = manifest?.passengers.firstWhere(
      (p) => p.id == passengerId,
    );

    if (passenger != null && !passenger.isCheckedIn) {
      passenger.isCheckedIn = true;
      passenger.checkInTime = DateTime.now();
      passenger.pendingSync = true;
      saveManifest();
    }
  }

  Future<void> syncCheckIns() async {
    if (!isOnline || manifest == null) return;

    try {
      final pendingPassengers = manifest!.passengers
          .where((p) => p.pendingSync)
          .toList();

      if (pendingPassengers.isEmpty) return;

      // TODO: Sync with server
      // For now, just mark as synced
      for (final passenger in pendingPassengers) {
        passenger.pendingSync = false;
      }

      await saveManifest();
    } catch (e) {
      debugPrint('Error syncing check-ins: $e');
    }
  }
}

class TripManifest {
  final String id;
  final String routeName;
  final String fromLocation;
  final String toLocation;
  final String departureTime;
  final String estimatedDuration;
  final List<Passenger> passengers;

  TripManifest({
    required this.id,
    required this.routeName,
    required this.fromLocation,
    required this.toLocation,
    required this.departureTime,
    required this.estimatedDuration,
    required this.passengers,
  });

  factory TripManifest.fromJson(Map<String, dynamic> json) {
    return TripManifest(
      id: json['id'],
      routeName: json['routeName'],
      fromLocation: json['fromLocation'],
      toLocation: json['toLocation'],
      departureTime: json['departureTime'],
      estimatedDuration: json['estimatedDuration'],
      passengers: (json['passengers'] as List)
          .map((p) => Passenger.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeName': routeName,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'departureTime': departureTime,
      'estimatedDuration': estimatedDuration,
      'passengers': passengers.map((p) => p.toJson()).toList(),
    };
  }
}

class Passenger {
  final String id;
  final String name;
  final String seatNumber;
  final String? phoneNumber;
  bool isCheckedIn;
  DateTime? checkInTime;
  bool pendingSync;

  Passenger({
    required this.id,
    required this.name,
    required this.seatNumber,
    this.phoneNumber,
    this.isCheckedIn = false,
    this.checkInTime,
    this.pendingSync = false,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'],
      name: json['name'],
      seatNumber: json['seatNumber'],
      phoneNumber: json['phoneNumber'],
      isCheckedIn: json['isCheckedIn'] ?? false,
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
      pendingSync: json['pendingSync'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'seatNumber': seatNumber,
      'phoneNumber': phoneNumber,
      'isCheckedIn': isCheckedIn,
      'checkInTime': checkInTime?.toIso8601String(),
      'pendingSync': pendingSync,
    };
  }
}
