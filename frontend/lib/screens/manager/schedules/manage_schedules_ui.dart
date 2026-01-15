part of 'manage_schedules_screen.dart';

Widget _buildSchedulesUI(_ManageSchedulesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  if (state._data.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return RefreshIndicator(
    onRefresh: state._refreshSchedules,
    child: Column(
      children: [
        // Schedules Summary
        _buildSchedulesSummary(state),
        const SizedBox(height: 16),

        // Schedules List
        Expanded(
          child: state._data.schedules.isEmpty
              ? _buildEmptySchedulesState(state)
              : _buildSchedulesList(state),
        ),
      ],
    ),
  );
}

Widget _buildSchedulesSummary(_ManageSchedulesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;
  final upcomingSchedules = state._data.getUpcomingSchedules();
  final activeSchedules = state._data.getActiveSchedules();

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: cs.shadow.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.schedule,
            title: 'Total Schedules',
            value: '${state._data.schedules.length}',
            color: cs.primary,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.upcoming,
            title: 'Upcoming',
            value: '${upcomingSchedules.length}',
            color: Colors.blue,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.play_arrow,
            title: 'Active',
            value: '${activeSchedules.length}',
            color: Colors.green,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSummaryItem({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
}) {
  return Column(
    children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        title,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildEmptySchedulesState(_ManageSchedulesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 80, color: cs.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No Schedules Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedules will appear here when created',
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildSchedulesList(_ManageSchedulesScreenState state) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: state._data.schedules.length,
    itemBuilder: (context, index) {
      final schedule = state._data.schedules[index];
      return _buildScheduleCard(state, schedule);
    },
  );
}

Widget _buildScheduleCard(
  _ManageSchedulesScreenState state,
  Schedule schedule,
) {
  final cs = Theme.of(state.context).colorScheme;

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Navigate to ServiceEditScreen with both serviceId and scheduleId for editing
        Navigator.push(
          state.context,
          MaterialPageRoute(
            builder: (_) => ServiceEditScreen(
              serviceId: schedule.serviceId,
              scheduleId: schedule.id,
            ),
          ),
        ).then((result) {
          if (result == true) {
            // Schedule was updated, refresh the list
            state._refreshSchedules();
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with route and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    schedule.routeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                _buildScheduleStatusBadge(schedule.status),
              ],
            ),

            const SizedBox(height: 8),

            // Vehicle and driver info
            Row(
              children: [
                Icon(Icons.directions_bus, size: 16, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  schedule.vehicleNumber,
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: cs.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    schedule.driverName,
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Schedule details
            Row(
              children: [
                Expanded(
                  child: _buildScheduleDetail(
                    icon: Icons.access_time,
                    label: 'Departure',
                    value: _formatTime(schedule.departureTime),
                  ),
                ),
                Expanded(
                  child: _buildScheduleDetail(
                    icon: Icons.event_seat,
                    label: 'Available',
                    value: '${schedule.availableSeats}/${schedule.totalSeats}',
                  ),
                ),
                Expanded(
                  child: _buildScheduleDetail(
                    icon: Icons.attach_money,
                    label: 'Fare',
                    value:
                        'PKR ${(schedule.service?['base_price'] as num?)?.toDouble()?.toStringAsFixed(0) ?? 'N/A'}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Travel date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  'Travel Date: ${_formatDate(schedule.travelDate)}',
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Edit schedule
                    ScaffoldMessenger.of(state.context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit Schedule - Coming Soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildScheduleDetail({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Column(
    children: [
      Icon(icon, size: 20, color: Colors.grey[600]),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
        textAlign: TextAlign.center,
      ),
      Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildScheduleStatusBadge(ScheduleStatus status) {
  late Color color;
  late String text;

  switch (status) {
    case ScheduleStatus.scheduled:
      color = Colors.blue;
      text = 'Scheduled';
      break;
    case ScheduleStatus.inProgress:
      color = Colors.green;
      text = 'In Progress';
      break;
    case ScheduleStatus.completed:
      color = Colors.grey;
      text = 'Completed';
      break;
    case ScheduleStatus.cancelled:
      color = Colors.red;
      text = 'Cancelled';
      break;
    case ScheduleStatus.delayed:
      color = Colors.orange;
      text = 'Delayed';
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}
