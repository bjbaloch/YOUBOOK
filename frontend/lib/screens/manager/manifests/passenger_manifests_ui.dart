part of 'passenger_manifests_screen.dart';

Widget _buildManifestsUI(_PassengerManifestsScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  if (state._data.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return RefreshIndicator(
    onRefresh: state._refreshManifests,
    child: Column(
      children: [
        // Manifests Summary
        _buildManifestsSummary(state),
        const SizedBox(height: 16),

        // Schedules List
        Expanded(
          child: state._data.schedules.isEmpty
              ? _buildEmptyManifestsState(state)
              : _buildSchedulesWithManifestsList(state),
        ),
      ],
    ),
  );
}

Widget _buildManifestsSummary(_PassengerManifestsScreenState state) {
  final cs = Theme.of(state.context).colorScheme;
  final totalSchedules = state._data.schedules.length;
  final totalPassengers = state._data.schedules.fold<int>(
    0,
    (sum, schedule) => sum + (schedule.totalSeats - schedule.availableSeats),
  );

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      //color: cs.surface,
      gradient: LinearGradient(
        colors: [
          AppColors.lightSeaGreen.withOpacity(0.6),
          AppColors.lightSeaGreen.withOpacity(0.04),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
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
            title: 'Schedules',
            value: '$totalSchedules',
            color: cs.primary,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.people,
            title: 'Total Passengers',
            value: '$totalPassengers',
            color: Colors.blue,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.check_circle,
            title: 'Active',
            value: '${state._data.schedules.where((s) => s.isActive).length}',
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

Widget _buildEmptyManifestsState(_PassengerManifestsScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 80, color: cs.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No Passenger Manifests',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manifests will appear here when passengers book tickets',
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

Widget _buildSchedulesWithManifestsList(_PassengerManifestsScreenState state) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: state._data.schedules.length,
    itemBuilder: (context, index) {
      final schedule = state._data.schedules[index];
      return _buildScheduleManifestCard(state, schedule);
    },
  );
}

Widget _buildScheduleManifestCard(
  _PassengerManifestsScreenState state,
  Schedule schedule,
) {
  final cs = Theme.of(state.context).colorScheme;
  final passengerCount = schedule.totalSeats - schedule.availableSeats;

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO: Navigate to detailed manifest
        ScaffoldMessenger.of(state.context).showSnackBar(
          SnackBar(content: Text('Manifest for: ${schedule.routeName}')),
        );
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

            // Schedule info
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  '${_formatTime(schedule.departureTime)} - ${_formatDate(schedule.travelDate)}',
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Manifest summary
            Row(
              children: [
                Expanded(
                  child: _buildManifestDetail(
                    icon: Icons.people,
                    label: 'Passengers',
                    value: '$passengerCount/${schedule.totalSeats}',
                  ),
                ),
                Expanded(
                  child: _buildManifestDetail(
                    icon: Icons.directions_bus,
                    label: 'Vehicle',
                    value: schedule.vehicleNumber,
                  ),
                ),
                Expanded(
                  child: _buildManifestDetail(
                    icon: Icons.person,
                    label: 'Driver',
                    value: schedule.driverName
                        .split(' ')
                        .first, // First name only
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
                    // TODO: View detailed manifest
                    ScaffoldMessenger.of(state.context).showSnackBar(
                      const SnackBar(
                        content: Text('View Detailed Manifest - Coming Soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Manifest'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Export manifest
                    ScaffoldMessenger.of(state.context).showSnackBar(
                      const SnackBar(
                        content: Text('Export Manifest - Coming Soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildManifestDetail({
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
