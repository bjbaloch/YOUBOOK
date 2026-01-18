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
        // Services Summary
        _buildServicesSummary(state),
        const SizedBox(height: 16),

        // Services List
        Expanded(
          child: state._data.vehicles.isEmpty
              ? _buildEmptyServicesState(state)
              : _buildServicesList(state),
        ),
      ],
    ),
  );
}

Widget _buildServicesSummary(_TrackVehiclesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

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
            icon: Icons.business,
            title: 'Total Services',
            value: '${state._data.vehicles.length}',
            color: cs.primary,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.directions_bus,
            title: 'Bus Services',
            value:
                '${state._data.vehicles.where((s) => s['type'] == 'bus').length}',
            color: Colors.blue,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.airport_shuttle,
            title: 'Van Services',
            value:
                '${state._data.vehicles.where((s) => s['type'] == 'van').length}',
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

Widget _buildEmptyServicesState(_TrackVehiclesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business, size: 80, color: cs.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No Services Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Services will appear here when added',
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

Widget _buildServicesList(_TrackVehiclesScreenState state) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: state._data.vehicles.length,
    itemBuilder: (context, index) {
      final service = state._data.vehicles[index] as Map<String, dynamic>;
      return _buildServiceCard(state, service);
    },
  );
}

Widget _buildServiceCard(
  _TrackVehiclesScreenState state,
  Map<String, dynamic> service,
) {
  final cs = Theme.of(state.context).colorScheme;
  final serviceType = service['type'] as String? ?? 'unknown';
  final serviceName = service['name'] as String? ?? 'Unnamed Service';
  final capacity = service['capacity'] as int? ?? 0;
  final basePrice = service['base_price'] as num? ?? 0;
  final routeName = service['route_name'] as String? ?? 'No route';

  // Choose icon based on service type
  IconData serviceIcon;
  Color serviceColor;
  if (serviceType == 'bus') {
    serviceIcon = Icons.directions_bus;
    serviceColor = Colors.blue;
  } else if (serviceType == 'van') {
    serviceIcon = Icons.airport_shuttle;
    serviceColor = Colors.green;
  } else {
    serviceIcon = Icons.business;
    serviceColor = cs.primary;
  }

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with service type and name
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: serviceColor.withOpacity(0.1),
                child: Icon(serviceIcon, color: serviceColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      serviceType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Service details
          Row(
            children: [
              Expanded(
                child: _buildVehicleDetail(
                  icon: Icons.people,
                  label: 'Capacity',
                  value: '${capacity} seats',
                ),
              ),
              Expanded(
                child: _buildVehicleDetail(
                  icon: Icons.attach_money,
                  label: 'Base Fare',
                  value: 'PKR ${basePrice.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _buildVehicleDetail(
                  icon: Icons.route,
                  label: 'Route',
                  value: routeName.length > 15
                      ? '${routeName.substring(0, 15)}...'
                      : routeName,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Route information
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
                    routeName,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: Track vehicles for this service
                  ScaffoldMessenger.of(state.context).showSnackBar(
                    SnackBar(
                      content: Text('Track vehicles for ${serviceName}'),
                    ),
                  );
                },
                icon: const Icon(Icons.track_changes, size: 16),
                label: const Text('Track Vehicle'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  // Navigate to service edit screen
                  Navigator.push(
                    state.context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ServiceEditScreen(serviceId: service['id']),
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
