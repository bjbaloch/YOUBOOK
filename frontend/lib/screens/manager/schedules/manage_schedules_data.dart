part of 'manage_schedules_screen.dart';

class ManageSchedulesData {
  List<Schedule> schedules = [];
  bool isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> loadSchedules() async {
    isLoading = true;
    try {
      final schedulesData = await _apiService.getManagerSchedules();
      schedules = schedulesData.map((json) => Schedule.fromJson(json)).toList();
      // Sort by departure time (upcoming first)
      schedules.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    } catch (e) {
      // On error, keep empty list
      schedules = [];
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  List<Schedule> getUpcomingSchedules() {
    return schedules.where((s) => s.isUpcoming).toList();
  }

  List<Schedule> getActiveSchedules() {
    return schedules.where((s) => s.isActive).toList();
  }

  List<Schedule> getSchedulesByDate(DateTime date) {
    return schedules.where((s) =>
        s.travelDate.year == date.year &&
        s.travelDate.month == date.month &&
        s.travelDate.day == date.day).toList();
  }

  List<Schedule> getSchedulesByStatus(ScheduleStatus status) {
    return schedules.where((s) => s.status == status).toList();
  }
}
