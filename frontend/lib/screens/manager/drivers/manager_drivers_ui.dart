part of 'manager_drivers_screen.dart';

Widget _buildDriversUI(_ManagerDriversScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  if (state._data.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return RefreshIndicator(
    onRefresh: state._refreshDrivers,
    child: Column(
      children: [
        // Drivers Summary
        _buildDriversSummary(state),
        const SizedBox(height: 16),

        // Drivers List
        Expanded(
          child: state._data.drivers.isEmpty
              ? _buildEmptyDriversState(state)
              : _buildDriversList(state),
        ),
      ],
    ),
  );
}

Widget _buildDriversSummary(_ManagerDriversScreenState state) {
  final cs = Theme.of(state.context).colorScheme;
  final activeDrivers = state._data.getActiveDrivers();
  final availableDrivers = state._data.getAvailableDrivers();
  final onDutyDrivers = state._data.getOnDutyDrivers();

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
            icon: Icons.people,
            title: 'Total Drivers',
            value: '${state._data.drivers.length}',
            color: cs.primary,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.check_circle,
            title: 'Active',
            value: '${activeDrivers.length}',
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.directions_car,
            title: 'On Duty',
            value: '${onDutyDrivers.length}',
            color: Colors.blue,
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

Widget _buildEmptyDriversState(_ManagerDriversScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 80, color: cs.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No Drivers Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Drivers will appear here when added',
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

Widget _buildDriversList(_ManagerDriversScreenState state) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: state._data.drivers.length,
    itemBuilder: (context, index) {
      final driver = state._data.drivers[index];
      return _buildDriverCard(state, driver);
    },
  );
}

Widget _buildDriverCard(_ManagerDriversScreenState state, Driver driver) {
  final cs = Theme.of(state.context).colorScheme;

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO: Navigate to driver details
        ScaffoldMessenger.of(state.context).showSnackBar(
          SnackBar(content: Text('Driver Details: ${driver.fullName}')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: cs.primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        driver.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDriverStatusBadge(driver.status),
              ],
            ),

            const SizedBox(height: 12),

            // Driver details
            Row(
              children: [
                Expanded(
                  child: _buildDriverDetail(
                    icon: Icons.badge,
                    label: 'License',
                    value: driver.licenseNumber,
                  ),
                ),
                Expanded(
                  child: _buildDriverDetail(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: driver.phoneNumber,
                  ),
                ),
                Expanded(
                  child: _buildDriverDetail(
                    icon: Icons.star,
                    label: 'Rating',
                    value: '${driver.rating.toStringAsFixed(1)} ⭐',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Vehicle assignment and duty status
            if (driver.isOnDuty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_car, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Assigned to: ${driver.currentVehicleNumber}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (driver.isAvailable) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Available for assignment',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // License validity
            Row(
              children: [
                Icon(
                  driver.isLicenseValid ? Icons.verified : Icons.warning,
                  size: 16,
                  color: driver.isLicenseValid ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  driver.isLicenseValid
                      ? 'License Valid'
                      : 'License Expires Soon',
                  style: TextStyle(
                    color: driver.isLicenseValid ? Colors.green : Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
                    // TODO: Edit driver
                    ScaffoldMessenger.of(state.context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit Driver - Coming Soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Assign vehicle
                    ScaffoldMessenger.of(state.context).showSnackBar(
                      SnackBar(
                        content: Text('Assign Vehicle: ${driver.fullName}'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_car, size: 16),
                  label: const Text('Assign'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDriverDetail({
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

Widget _buildDriverStatusBadge(DriverStatus status) {
  late Color color;
  late String text;

  switch (status) {
    case DriverStatus.idle:
      color = Colors.green;
      text = 'Idle';
      break;
    case DriverStatus.assigned:
      color = Colors.blue;
      text = 'Assigned';
      break;
    case DriverStatus.onTrip:
      color = Colors.orange;
      text = 'On Trip';
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
