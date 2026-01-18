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
      //color: cs.surface,
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
                schedule.serviceName,
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
                  // Navigate to ServiceEditScreen
                  Navigator.push(
                    state.context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ServiceEditScreen(serviceId: schedule.serviceId),
                    ),
                  ).then((result) {
                    if (result == true) {
                      // Service was updated, refresh the list
                      state._refreshSchedules();
                    }
                  });
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

// Create Schedule Dialog
class CreateScheduleDialog extends StatefulWidget {
  const CreateScheduleDialog({super.key});

  @override
  State<CreateScheduleDialog> createState() => _CreateScheduleDialogState();
}

class _CreateScheduleDialogState extends State<CreateScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  DateTime? _selectedDate;
  String? _selectedServiceId;
  List<Map<String, dynamic>> _availableServices = [];
  bool _isLoading = false;
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableServices();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAvailableServices() async {
    setState(() {
      _isLoadingServices = true;
    });

    try {
      final services = await _apiService.getManagerServices();
      debugPrint('Loaded ${services.length} services for manager');

      // Debug: Log service details
      for (final service in services) {
        debugPrint(
          'Service: ${service['id']} - Name: ${service['name']} - Type: ${service['type']} - Status: ${service['status']}',
        );
      }

      if (mounted) {
        setState(() {
          _availableServices = services;
          _isLoadingServices = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading services: $e');
      if (mounted) {
        setState(() {
          _isLoadingServices = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load services: $e')));
      }
    }
  }

  // Refresh services list - useful when new services are added
  Future<void> _refreshServices() async {
    await _loadAvailableServices();
  }

  Future<void> _pickTravelDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (date != null && mounted) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _createSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a service')));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a travel date')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Find the selected service
      final selectedService = _availableServices.firstWhere(
        (s) => s['id'] == _selectedServiceId,
      );

      // Create a default vehicle for this service if none exists
      final existingVehicles = await _apiService.getServiceVehicles(
        _selectedServiceId!,
      );
      String vehicleId;

      if (existingVehicles.isEmpty) {
        // Create a default vehicle for this service
        final vehicleData = {
          'service_id': _selectedServiceId,
          'type': selectedService['type'], // 'bus' or 'van'
          'registration_number':
              'AUTO-${DateTime.now().millisecondsSinceEpoch}',
          'vehicle_number': 'AUTO-${DateTime.now().millisecondsSinceEpoch}',
          'make': selectedService['name'] ?? 'Default Vehicle',
          'model': selectedService['name'] ?? 'Default Vehicle',
          'capacity': selectedService['capacity'] ?? 50,
          'year': DateTime.now().year,
          'status': 'active',
          'fuel_type': 'diesel',
          'is_active': true,
        };

        final newVehicle = await _apiService.createVehicle(vehicleData);
        vehicleId = newVehicle['id'];
      } else {
        // Use the first existing vehicle
        vehicleId = existingVehicles.first['id'];
      }

      // Use service data for schedule details
      final scheduleData = {
        'service_id': _selectedServiceId,
        'vehicle_id': vehicleId,
        'origin': selectedService['from_location'] ?? '',
        'destination': selectedService['to_location'] ?? '',
        'departure_time':
            selectedService['departure_time'] ??
            DateTime.now().toIso8601String(),
        'arrival_time':
            selectedService['arrival_time'] ??
            DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
        'travel_date': _selectedDate!.toIso8601String().split('T')[0],
        'total_seats': selectedService['capacity'] ?? 50,
        'base_fare': (selectedService['base_price'] as num?)?.toDouble() ?? 0.0,
      };

      final result = await _apiService.createSchedule(scheduleData);

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create schedule: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.schedule, color: cs.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Create New Schedule',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Service Selection
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Select Service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoadingServices ? null : _refreshServices,
                        icon: Icon(Icons.refresh, color: cs.primary, size: 20),
                        tooltip: 'Refresh service list',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _isLoadingServices
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          value: _selectedServiceId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          hint: const Text('Choose a service'),
                          items: _availableServices.map((service) {
                            final name =
                                service['name']?.toString().trim() ??
                                'Unnamed Service';
                            final type =
                                service['type']?.toString().toUpperCase() ??
                                'SERVICE';

                            final displayName = '$type: $name';

                            return DropdownMenuItem<String>(
                              value: service['id'],
                              child: Text(displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedServiceId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a service';
                            }
                            return null;
                          },
                        ),

                  const SizedBox(height: 16),

                  // Travel Date
                  InkWell(
                    onTap: _pickTravelDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Travel Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select travel date',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _createSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Create Schedule'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
