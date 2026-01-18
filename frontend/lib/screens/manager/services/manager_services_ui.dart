part of 'manager_services_screen.dart';

String _getActualSeatCount(Service service) {
  if (service.seatLayout != null && service.seatLayout!['totalSeats'] != null) {
    return service.seatLayout!['totalSeats'].toString();
  }
  return service.capacity.toString();
}

void _navigateToAddService(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ServicesPage()),
  );
}

void _navigateToServiceEdit(
  BuildContext context,
  String serviceId,
  _ManagerServicesScreenState state,
) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ServiceEditScreen(serviceId: serviceId)),
  ).then((result) {
    if (result == true) {
      // Service was updated, refresh the list to show updated values
      state._refreshServices();
    }
  });
}

Widget _buildServicesUI(_ManagerServicesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  if (state._data.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: () => _navigateToAddService(state.context),
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      child: const Icon(Icons.add),
    ),
    body: RefreshIndicator(
      onRefresh: state._initializeServices,
      child: Column(
        children: [
          // Services Summary
          _buildServicesSummary(state),
          const SizedBox(height: 16),

          // Services List
          Expanded(
            child: state._data.services.isEmpty
                ? _buildEmptyState(state)
                : _buildServicesList(state),
          ),
        ],
      ),
    ),
  );
}

Widget _buildServicesSummary(_ManagerServicesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;
  final activeServices = state._data.getActiveServices();
  final pausedServices = state._data.getPausedServices();

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        colors: [
          AppColors.lightSeaGreen.withOpacity(0.6),
          AppColors.lightSeaGreen.withOpacity(0.04),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
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
            value: '${state._data.services.length}',
            color: cs.primary,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.check_circle,
            title: 'Active Services',
            value: '${activeServices.length}',
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.pause_circle,
            title: 'Paused Services',
            value: '${pausedServices.length}',
            color: Colors.orange,
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

Widget _buildEmptyState(_ManagerServicesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center,
            size: 80,
            color: cs.onSurface.withOpacity(0.3),
          ),
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

Widget _buildServicesList(_ManagerServicesScreenState state) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: state._data.services.length,
    itemBuilder: (context, index) {
      final service = state._data.services[index];
      return _buildServiceCard(state, service);
    },
  );
}

Widget _buildServiceCard(_ManagerServicesScreenState state, Service service) {
  final cs = Theme.of(state.context).colorScheme;

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () => _navigateToServiceEdit(state.context, service.id, state),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(service.status),
                    const SizedBox(height: 4),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: cs.onSurface.withOpacity(0.6),
                        size: 20,
                      ),
                      onSelected: (String action) async {
                        if (action.startsWith('service_')) {
                          final statusStr = action.replaceFirst('service_', '');
                          final newStatus = ServiceStatus.values.firstWhere(
                            (s) => s.name == statusStr,
                          );
                          await _updateServiceStatus(
                            state,
                            service.id,
                            newStatus,
                          );
                        } else if (action == 'vehicle_status') {
                          await _showVehicleStatusDialog(
                            state.context,
                            service,
                            state._dataService,
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        // Service status options
                        PopupMenuItem<String>(
                          value: 'service_active',
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(ServiceStatus.active),
                                color: _getStatusColor(ServiceStatus.active),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Service: Active',
                                style: TextStyle(
                                  color: service.status == ServiceStatus.active
                                      ? cs.primary
                                      : cs.onSurface,
                                  fontWeight:
                                      service.status == ServiceStatus.active
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (service.status == ServiceStatus.active) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.check, color: cs.primary, size: 16),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'service_inactive',
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(ServiceStatus.inactive),
                                color: _getStatusColor(ServiceStatus.inactive),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Service: Inactive',
                                style: TextStyle(
                                  color:
                                      service.status == ServiceStatus.inactive
                                      ? cs.primary
                                      : cs.onSurface,
                                  fontWeight:
                                      service.status == ServiceStatus.inactive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (service.status == ServiceStatus.inactive) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.check, color: cs.primary, size: 16),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'service_maintenance',
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(ServiceStatus.maintenance),
                                color: _getStatusColor(
                                  ServiceStatus.maintenance,
                                ),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Service: Maintenance',
                                style: TextStyle(
                                  color:
                                      service.status ==
                                          ServiceStatus.maintenance
                                      ? cs.primary
                                      : cs.onSurface,
                                  fontWeight:
                                      service.status ==
                                          ServiceStatus.maintenance
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (service.status ==
                                  ServiceStatus.maintenance) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.check, color: cs.primary, size: 16),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'service_suspended',
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(ServiceStatus.suspended),
                                color: _getStatusColor(ServiceStatus.suspended),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Service: Suspended',
                                style: TextStyle(
                                  color:
                                      service.status == ServiceStatus.suspended
                                      ? cs.primary
                                      : cs.onSurface,
                                  fontWeight:
                                      service.status == ServiceStatus.suspended
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (service.status ==
                                  ServiceStatus.suspended) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.check, color: cs.primary, size: 16),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Route
            Row(
              children: [
                Icon(Icons.route, size: 16, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  service.route,
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Details
            Row(
              children: [
                Expanded(
                  child: _buildServiceDetail(
                    icon: Icons.attach_money,
                    label: 'Price',
                    value: 'PKR ${service.basePrice.toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _buildServiceDetail(
                    icon: Icons.people,
                    label: 'Capacity',
                    value: '${_getActualSeatCount(service)} seats',
                  ),
                ),
                Expanded(
                  child: _buildServiceDetail(
                    icon: Icons.star,
                    label: 'Type',
                    value: 'Transport', // All services are transport services
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Vehicle Credentials
            if (_hasVehicleCredentials(service)) ...[
              _buildVehicleCredentialsSection(service, cs),
              const SizedBox(height: 12),
            ],

            // Features (excluding WiFi)
            ..._buildFeaturesSection(service, cs),

            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

Widget _buildServiceDetail({
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

List<Widget> _buildFeaturesSection(Service service, ColorScheme cs) {
  final filteredFeatures = service.features
      .where((feature) => feature != 'WiFi')
      .toList();
  if (filteredFeatures.isEmpty) return [];

  return [
    Text(
      'Features:',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: cs.onSurface,
      ),
    ),
    const SizedBox(height: 4),
    Wrap(
      spacing: 6,
      runSpacing: 4,
      children: filteredFeatures.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            feature,
            style: TextStyle(
              fontSize: 12,
              color: cs.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    ),
  ];
}

bool _hasVehicleCredentials(Service service) {
  return service.vehicleNumber != null ||
      service.vehicleColor != null ||
      service.proprietor != null ||
      service.generalManager != null ||
      service.manager != null ||
      service.secretary != null;
}

Widget _buildVehicleCredentialsSection(Service service, ColorScheme cs) {
  final credentials = <Widget>[];

  // Vehicle Information
  if (service.vehicleNumber != null || service.vehicleColor != null) {
    credentials.add(
      Row(
        children: [
          Icon(Icons.directions_car, size: 16, color: cs.primary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Vehicle: ${service.vehicleNumber ?? 'N/A'} (${service.vehicleColor ?? 'N/A'})',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Proprietor Information
  if (service.proprietor != null ||
      service.generalManager != null ||
      service.manager != null ||
      service.secretary != null) {
    final proprietorInfo = [
      if (service.proprietor != null) 'Prop: ${service.proprietor}',
      if (service.generalManager != null) 'GM: ${service.generalManager}',
      if (service.manager != null) 'Mgr: ${service.manager}',
      if (service.secretary != null) 'Sec: ${service.secretary}',
    ].join(' | ');

    if (proprietorInfo.isNotEmpty) {
      credentials.add(
        Row(
          children: [
            Icon(Icons.business, size: 16, color: cs.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                proprietorInfo,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  if (credentials.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Vehicle Credentials:',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
      ),
      const SizedBox(height: 4),
      ...credentials,
    ],
  );
}

Future<void> _updateServiceStatus(
  _ManagerServicesScreenState state,
  String serviceId,
  ServiceStatus newStatus,
) async {
  try {
    final apiService = ApiService();
    final currentService = state._data.services.firstWhere(
      (s) => s.id == serviceId,
    );

    // Send ALL current service data with only status changed
    final updatedServiceData = await apiService.updateService(serviceId, {
      'name': currentService.name,
      'description': currentService.description,
      'type': 'transport',
      'status': newStatus.name,
      'base_price': currentService.basePrice,
      'capacity': currentService.capacity,
      'route': currentService.route,
      'features': currentService.features,
      'vehicle_number': currentService.vehicleNumber,
      'vehicle_color': currentService.vehicleColor,
      'proprietor': currentService.proprietor,
      'general_manager': currentService.generalManager,
      'manager': currentService.manager,
      'secretary': currentService.secretary,
      'from_location': currentService.fromLocation,
      'to_location': currentService.toLocation,
      'boarding_office': currentService.boardingOffice,
      'arrival_office': currentService.arrivalOffice,
      'departure_time': currentService.departureTime,
      'arrival_time': currentService.arrivalTime,
      'application_charges': currentService.applicationCharges,
      'seat_layout': currentService.seatLayout,
      'is_seat_layout_configured': currentService.isSeatLayoutConfigured,
    });

    // Update local service object with API response data
    final index = state._data.services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      // Use the API response to ensure data integrity
      state._data.services[index] = Service.fromJson(updatedServiceData);
    }

    // Force UI refresh to ensure all values remain visible
    state.setState(() {});

    if (state.mounted) {
      ScaffoldMessenger.of(state.context).showSnackBar(
        SnackBar(content: Text('Service status updated to ${newStatus.name}')),
      );
    }
  } catch (e) {
    if (state.mounted) {
      ScaffoldMessenger.of(
        state.context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }
}

IconData _getStatusIcon(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.active:
      return Icons.check_circle;
    case ServiceStatus.inactive:
      return Icons.cancel;
    case ServiceStatus.maintenance:
      return Icons.build;
    case ServiceStatus.suspended:
      return Icons.block;
  }
}

Color _getStatusColor(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.active:
      return Colors.green;
    case ServiceStatus.inactive:
      return Colors.grey;
    case ServiceStatus.maintenance:
      return Colors.orange;
    case ServiceStatus.suspended:
      return Colors.red;
  }
}

String _getStatusText(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.active:
      return 'Active';
    case ServiceStatus.inactive:
      return 'Inactive';
    case ServiceStatus.maintenance:
      return 'Maintenance';
    case ServiceStatus.suspended:
      return 'Suspended';
  }
}

Widget _buildStatusBadge(ServiceStatus status) {
  late Color color;
  late String text;

  switch (status) {
    case ServiceStatus.active:
      color = Colors.green;
      text = 'Active';
      break;
    case ServiceStatus.inactive:
      color = Colors.grey;
      text = 'Inactive';
      break;
    case ServiceStatus.maintenance:
      color = Colors.orange;
      text = 'Maintenance';
      break;
    case ServiceStatus.suspended:
      color = Colors.red;
      text = 'Suspended';
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

Future<void> _showVehicleStatusDialog(
  BuildContext context,
  Service service,
  ManagerDataService dataService,
) async {
  final serviceVehicles = dataService.vehicles
      .where((v) => v.serviceId == service.id)
      .toList();

  if (serviceVehicles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No vehicles found for this service')),
    );
    return;
  }

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Manage Vehicle Status'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: serviceVehicles.length,
          itemBuilder: (context, index) {
            final vehicle = serviceVehicles[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.directions_bus,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(vehicle.registrationNumber),
              subtitle: Text('${vehicle.make} ${vehicle.model}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getVehicleStatusColor(
                    vehicle.status,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getVehicleStatusColor(vehicle.status),
                  ),
                ),
                child: Text(
                  _getVehicleStatusText(vehicle.status),
                  style: TextStyle(
                    color: _getVehicleStatusColor(vehicle.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onTap: () async {
                // Show status selection dialog
                final newStatus = await _showVehicleStatusSelectionDialog(
                  context,
                  vehicle,
                );
                if (newStatus != null && newStatus != vehicle.status) {
                  try {
                    await dataService.updateVehicle(vehicle.id, {
                      'status': newStatus.name,
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Vehicle status updated to ${newStatus.name}',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update vehicle status: $e'),
                        ),
                      );
                    }
                  }
                }
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<VehicleStatus?> _showVehicleStatusSelectionDialog(
  BuildContext context,
  Vehicle vehicle,
) async {
  return await showDialog<VehicleStatus>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Change Status for ${vehicle.registrationNumber}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: VehicleStatus.values.map((status) {
          return ListTile(
            leading: Icon(
              _getVehicleStatusIcon(status),
              color: _getVehicleStatusColor(status),
            ),
            title: Text(_getVehicleStatusText(status)),
            selected: vehicle.status == status,
            onTap: () => Navigator.pop(context, status),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

IconData _getVehicleStatusIcon(VehicleStatus status) {
  switch (status) {
    case VehicleStatus.active:
      return Icons.check_circle;
    case VehicleStatus.maintenance:
      return Icons.build;
    case VehicleStatus.inactive:
      return Icons.cancel;
    default:
      return Icons.help;
  }
}

Color _getVehicleStatusColor(VehicleStatus status) {
  switch (status) {
    case VehicleStatus.active:
      return Colors.green;
    case VehicleStatus.maintenance:
      return Colors.orange;
    case VehicleStatus.inactive:
      return Colors.grey;
    default:
      return Colors.black;
  }
}

String _getVehicleStatusText(VehicleStatus status) {
  switch (status) {
    case VehicleStatus.active:
      return 'Active';
    case VehicleStatus.maintenance:
      return 'Maintenance';
    case VehicleStatus.inactive:
      return 'Inactive';
    default:
      return 'Unknown';
  }
}
