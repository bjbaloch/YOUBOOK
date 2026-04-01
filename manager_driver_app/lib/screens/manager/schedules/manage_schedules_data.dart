part of 'manage_schedules_screen.dart';

class ManageSchedulesData {
  final ManagerDataService _dataService;

  ManageSchedulesData(this._dataService);

  List<Schedule> get schedules => _dataService.schedules;
  bool get isLoading => _dataService.isLoadingSchedules;

  Future<void> loadSchedules() async {
    await _dataService.loadSchedules();
  }

  List<Schedule> getUpcomingSchedules() {
    return _dataService.getUpcomingSchedules();
  }

  List<Schedule> getActiveSchedules() {
    return _dataService.getActiveSchedules();
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
