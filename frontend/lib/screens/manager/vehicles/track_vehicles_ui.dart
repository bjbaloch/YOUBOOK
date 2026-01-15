part of 'track_vehicles_screen.dart';

Widget _buildVehiclesUI(_TrackVehiclesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  if (state._data.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return RefreshIndicator(
    onRefresh: state._refreshVehicles,
    child: Column(
      children: [
        // Vehicles Summary
        _buildVehiclesSummary(state),
        const SizedBox(height: 16),

        // Vehicles List
        Expanded(
          child: state._data.vehicles.isEmpty
              ? _buildEmptyVehiclesState(state)
              : _buildVehiclesList(state),
        ),
      ],
    ),
  );
}

Widget _buildVehiclesSummary(_TrackVehiclesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;
  final activeVehicles = state._data.getActiveVehicles();
  final inUseVehicles = state._data.getVehiclesInUse();
  final maintenanceVehicles = state._data.getVehiclesNeedingMaintenance();

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
            icon: Icons.directions_bus,
            title: 'Total Vehicles',
            value: '${state._data.vehicles.length}',
            color: cs.primary,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.check_circle,
            title: 'Active',
            value: '${activeVehicles.length}',
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.location_on,
            title: 'In Use',
            value: '${inUseVehicles.length}',
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

Widget _buildEmptyVehiclesState(_TrackVehiclesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus,
            size: 80,
            color: cs.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Vehicles Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vehicles will appear here when added',
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

Widget _buildVehiclesList(_TrackVehiclesScreenState state) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: state._data.vehicles.length,
    itemBuilder: (context, index) {
      final vehicle = state._data.vehicles[index];
      return _buildVehicleCard(state, vehicle);
    },
  );
}

Widget _buildVehicleCard(_TrackVehiclesScreenState state, Vehicle vehicle) {
  final cs = Theme.of(state.context).colorScheme;

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO: Navigate to vehicle details/map
        ScaffoldMessenger.of(state.context).showSnackBar(
          SnackBar(content: Text('Track Vehicle: ${vehicle.registrationNumber}')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with registration and status
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: cs.primary.withOpacity(0.1),
                  child: Icon(Icons.directions_bus, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.registrationNumber,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        vehicle.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildVehicleStatusBadge(vehicle.status),
              ],
            ),

            const SizedBox(height: 12),

            // Vehicle details
            Row(
              children: [
                Expanded(
                  child: _buildVehicleDetail(
                    icon: Icons.person,
                    label: 'Driver',
                    value: vehicle.driverName,
                  ),
                ),
                Expanded(
                  child: _buildVehicleDetail(
                    icon: Icons.people,
                    label: 'Capacity',
                    value: '${vehicle.capacity} seats',
                  ),
                ),
                Expanded(
                  child: _buildVehicleDetail(
                    icon: Icons.speed,
                    label: 'Mileage',
                    value: '${vehicle.totalKm} km',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Location and maintenance status
            if (vehicle.currentLocation != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vehicle.currentLocation!,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (vehicle.isInUse) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'On active route',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pause, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Parked/Available',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Maintenance warning
            if (vehicle.needsMaintenance) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Maintenance due soon',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Track on map
                    ScaffoldMessenger.of(state.context).showSnackBar(
                      const SnackBar(content: Text('Track on Map - Coming Soon!')),
                    );
                  },
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('Track'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: View vehicle details
                    ScaffoldMessenger.of(state.context).showSnackBar(
                      SnackBar(content: Text('Vehicle Details: ${vehicle.registrationNumber}')),
                    );
                  },
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildVehicleDetail({
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

Widget _buildVehicleStatusBadge(VehicleStatus status) {
  late Color color;
  late String text;

  switch (status) {
    case VehicleStatus.active:
      color = Colors.green;
      text = 'Active';
      break;
    case VehicleStatus.maintenance:
      color = Colors.orange;
      text = 'Maintenance';
      break;
    case VehicleStatus.inactive:
      color = Colors.grey;
      text = 'Inactive';
      break;
    case VehicleStatus.outOfService:
      color = Colors.red;
      text = 'Out of Service';
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
