part of 'passenger_manifests_screen.dart';

class ManifestPassenger {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String seatNumber;
  final bool checkedIn;

  ManifestPassenger({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.seatNumber,
    required this.checkedIn,
  });

  factory ManifestPassenger.fromJson(Map<String, dynamic> json) {
    return ManifestPassenger(
      id: json['id']?.toString() ?? '',
      name: json['full_name'] ?? json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone_number'] ?? json['phone'] ?? '',
      seatNumber: json['seat_number'] ?? 'N/A',
      checkedIn: json['checked_in'] ?? false,
    );
  }
}

class PassengerManifestsData {
  List<Schedule> schedules = [];
  Map<String, List<ManifestPassenger>> manifests = {};
  bool isLoading = false;

  Future<void> loadSchedules() async {
    isLoading = true;
    // TODO: Restore API call when connecting backend
    schedules = [];
    isLoading = false;
  }

  Future<void> loadManifestForSchedule(String scheduleId) async {
    if (manifests.containsKey(scheduleId)) return;
    // TODO: Restore API call when connecting backend
    manifests[scheduleId] = [];
  }

  List<ManifestPassenger>? getManifestForSchedule(String scheduleId) {
    return manifests[scheduleId];
  }

  int getTotalPassengers(String scheduleId) {
    return manifests[scheduleId]?.length ?? 0;
  }

  int getCheckedInPassengers(String scheduleId) {
    return manifests[scheduleId]?.where((p) => p.checkedIn).length ?? 0;
  }
}
