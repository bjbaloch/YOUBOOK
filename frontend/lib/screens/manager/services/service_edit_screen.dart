import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../features/services_details/bus_details/bus_seatlayout/UI/bus_seatlayout_ui.dart';
import '../../../features/services_details/van_details/van_seatlayout/UI/van_seatlayout_ui.dart';
import 'service_model.dart';

class ServiceEditScreen extends StatefulWidget {
  final String serviceId;
  final String? scheduleId; // Optional: for schedule editing mode

  const ServiceEditScreen({
    super.key,
    required this.serviceId,
    this.scheduleId,
  });

  @override
  State<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  bool _isLoading = true;
  Service? _service;
  late ServiceStatus _selectedStatus;

  // Controllers for all fields
  late TextEditingController _nameController;
  late TextEditingController _vehicleNumberController;
  late TextEditingController _vehicleColorController;
  late TextEditingController _proprietorController;
  late TextEditingController _generalManagerController;
  late TextEditingController _managerController;
  late TextEditingController _secretaryController;
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late TextEditingController _boardingOfficeController;
  late TextEditingController _arrivalOfficeController;
  late TextEditingController _departureTimeController;
  late TextEditingController _arrivalTimeController;
  late TextEditingController _priceController;
  late TextEditingController _applicationController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers first
    _initializeControllers();

    // Add listener to automatically calculate application charges
    _priceController.addListener(_updateApplicationCharges);

    // Load service data
    _loadService();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _vehicleNumberController = TextEditingController();
    _vehicleColorController = TextEditingController();
    _proprietorController = TextEditingController();
    _generalManagerController = TextEditingController();
    _managerController = TextEditingController();
    _secretaryController = TextEditingController();
    _fromController = TextEditingController();
    _toController = TextEditingController();
    _boardingOfficeController = TextEditingController();
    _arrivalOfficeController = TextEditingController();
    _departureTimeController = TextEditingController();
    _arrivalTimeController = TextEditingController();
    _priceController = TextEditingController();
    _applicationController = TextEditingController();
  }

  Future<void> _loadService() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final serviceData = await apiService.getServiceById(widget.serviceId);
      _service = Service.fromJson(serviceData);
      _selectedStatus = _service!.status;

      // Debug: Print service data to check if proprietor/office data is loaded
      print(
        'DEBUG: Service data - Proprietor: ${_service!.proprietor}, GeneralManager: ${_service!.generalManager}, Manager: ${_service!.manager}, Secretary: ${_service!.secretary}',
      );
      print(
        'DEBUG: Service data - BoardingOffice: ${_service!.boardingOffice}, ArrivalOffice: ${_service!.arrivalOffice}',
      );

      // Ensure vehicle records exist for this service (for scheduling)
      await _ensureServiceVehiclesExist(apiService, serviceData);

      // Update existing controllers with service data
      setState(() {
        _nameController.text = _service!.name;
        _vehicleNumberController.text = _service!.vehicleNumber ?? '';
        _vehicleColorController.text = _service!.vehicleColor ?? '';
        _proprietorController.text = _service!.proprietor ?? '';
        _generalManagerController.text = _service!.generalManager ?? '';
        _managerController.text = _service!.manager ?? '';
        _secretaryController.text = _service!.secretary ?? '';
        _fromController.text = _service!.fromLocation ?? '';
        _toController.text = _service!.toLocation ?? '';
        _boardingOfficeController.text = _service!.boardingOffice ?? '';
        _arrivalOfficeController.text = _service!.arrivalOffice ?? '';
        _departureTimeController.text = _service!.departureTime ?? '';
        _arrivalTimeController.text = _service!.arrivalTime ?? '';
        _priceController.text = _service!.basePrice.toString();
        _applicationController.text =
            _service!.applicationCharges?.toString() ?? '0.0';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load service: $e')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateApplicationCharges() {
    final text = _priceController.text.trim();
    if (text.isEmpty) {
      _applicationController.text = '';
      return;
    }
    final price = double.tryParse(text);
    if (price != null) {
      final charges = price * 0.03; // 3% of price per seat
      _applicationController.text = charges.toStringAsFixed(2);
    } else {
      _applicationController.text = '';
    }
  }

  @override
  void dispose() {
    _priceController.removeListener(
      _updateApplicationCharges,
    ); // Remove listener
    _nameController.dispose();
    _vehicleNumberController.dispose();
    _vehicleColorController.dispose();
    _proprietorController.dispose();
    _generalManagerController.dispose();
    _managerController.dispose();
    _secretaryController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _boardingOfficeController.dispose();
    _arrivalOfficeController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    _priceController.dispose();
    _applicationController.dispose();
    super.dispose();
  }

  Future<void> _updateServiceStatusOnly(ServiceStatus newStatus) async {
    try {
      final apiService = ApiService();
      await apiService.updateService(_service!.id, {
        'name': _service!.name, // Required field - cannot be null
        'type': 'transport', // Required field - correct database enum value
        'status': newStatus.name,
      });

      // Update local service object and UI
      setState(() {
        _service!.status = newStatus;
        _selectedStatus = newStatus;
      });

      // Trigger parent screen refresh by returning true
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Service status updated to ${newStatus.name}'),
          ),
        );
        // Return true to trigger parent refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  Future<void> _updateService() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final updateData = {
        'name': _nameController.text.trim(),
        'type': 'transport', // All services in this app are transport services
        'vehicle_number': _vehicleNumberController.text.trim(),
        'vehicle_color': _vehicleColorController.text.trim(),
        'proprietor': _proprietorController.text.trim(),
        'general_manager': _generalManagerController.text.trim(),
        'manager': _managerController.text.trim(),
        'secretary': _secretaryController.text.trim(),
        'from_location': _fromController.text.trim(),
        'to_location': _toController.text.trim(),
        'boarding_office': _boardingOfficeController.text.trim(),
        'arrival_office': _arrivalOfficeController.text.trim(),
        'departure_time': _departureTimeController.text.trim(),
        'arrival_time': _arrivalTimeController.text.trim(),
        'base_price':
            double.tryParse(_priceController.text) ?? _service!.basePrice,
        'application_charges':
            double.tryParse(_applicationController.text) ?? 0.0,
        'status': _selectedStatus.name,
      };

      await apiService.updateService(_service!.id, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update service: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _ensureServiceVehiclesExist(
    ApiService apiService,
    Map<String, dynamic> serviceData,
  ) async {
    try {
      // Check if service has vehicle information
      final hasVehicleInfo =
          serviceData['vehicle_number'] != null ||
          serviceData['vehicle_color'] != null ||
          serviceData['proprietor'] != null;

      if (!hasVehicleInfo) {
        // Service doesn't have vehicle information, skip
        return;
      }

      // Check if vehicle records already exist for this service
      final existingVehicles = await apiService.getServiceVehicles(
        widget.serviceId,
      );

      if (existingVehicles.isNotEmpty) {
        // Vehicles already exist, no need to create
        return;
      }

      // Create vehicle record from service data
      final vehicleData = {
        'service_id': widget.serviceId,
        'type': serviceData['type'] == 'van' ? 'van' : 'bus',
        'busName': serviceData['name'] ?? 'Service Vehicle',
        'vanName': serviceData['name'] ?? 'Service Vehicle',
        'busNumber':
            serviceData['vehicle_number'] ??
            'DEFAULT-${DateTime.now().millisecondsSinceEpoch}',
        'vanNumber':
            serviceData['vehicle_number'] ??
            'DEFAULT-${DateTime.now().millisecondsSinceEpoch}',
        'busColor': serviceData['vehicle_color'] ?? 'Default',
        'vanColor': serviceData['vehicle_color'] ?? 'Default',
        'seatLayoutData': {
          'totalSeats': serviceData['capacity'] ?? 50,
          'configured': serviceData['is_seat_layout_configured'] ?? false,
        },
      };

      await apiService.createVehicle(vehicleData);
      // Vehicle created successfully, now schedule creation can find it
    } catch (e) {
      // If vehicle creation fails, log but don't block service loading
      // The schedule creation will handle the missing vehicle gracefully
      debugPrint('Failed to ensure vehicle exists for service: $e');
    }
  }

  Future<void> _deleteService() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text(
          'Are you sure you want to delete this service? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      await apiService.deleteService(_service!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete service: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _scheduleTrip() async {
    await showDialog(
      context: context,
      builder: (context) => ScheduleTripDialog(
        serviceId: _service!.id,
        fromLocation: _fromController.text,
        toLocation: _toController.text,
        capacity: _service!.capacity,
      ),
    );
  }

  Future<void> _pickDateTime(TextEditingController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        controller.text = combinedDateTime.toString();
      }
    }
  }

  Widget _buildServiceCredentialsCard(Service service) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                _buildStatusBadge(service.status),
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
                    value: '${service.capacity} seats',
                  ),
                ),
                Expanded(
                  child: _buildServiceDetail(
                    icon: Icons.star,
                    label: 'Type',
                    value: 'Transport',
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
          ],
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
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            toolbarHeight: 45,
            elevation: 0,
            title: const Text(
              'Edit Service Details',
              style: TextStyle(fontSize: 20),
            ),
            centerTitle: true,
            backgroundColor: cs.primary,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _isLoading ? null : _deleteService,
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Service Credentials Summary Card
                      if (_service != null)
                        _buildServiceCredentialsCard(_service!),
                      const SizedBox(height: 16),
                      _VehicleInformationSection(
                        nameController: _nameController,
                        numberController: _vehicleNumberController,
                        colorController: _vehicleColorController,
                      ),
                      _ProprietorInformationSection(
                        proprietorController: _proprietorController,
                        generalManagerController: _generalManagerController,
                        managerController: _managerController,
                        secretaryController: _secretaryController,
                      ),
                      _RouteInformationSection(
                        fromController: _fromController,
                        toController: _toController,
                      ),
                      _OfficeTerminalSection(
                        boardingController: _boardingOfficeController,
                        arrivalController: _arrivalOfficeController,
                      ),
                      _ScheduleDetailsSection(
                        departureController: _departureTimeController,
                        arrivalController: _arrivalTimeController,
                        onPickDateTime: _pickDateTime,
                      ),
                      _SeatPricingSection(
                        priceController: _priceController,
                        applicationController: _applicationController,
                        service: _service!,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _scheduleTrip,
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Schedule Trip'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _updateService,
                              icon: const Icon(Icons.save),
                              label: const Text('Update Service'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ---------- Section Widgets ----------

class SectionHeader extends StatelessWidget {
  final String titleEn;
  final String titleUr;
  final bool isRequired;

  const SectionHeader({
    super.key,
    required this.titleEn,
    required this.titleUr,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
                children: [
                  TextSpan(text: '$titleEn ($titleUr)'),
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomInputField extends StatefulWidget {
  final String labelEn;
  final String labelUr;
  final bool isRequired;
  final TextEditingController? controller;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomInputField({
    super.key,
    required this.labelEn,
    required this.labelUr,
    this.isRequired = false,
    this.controller,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: TextFormField(
          controller: widget.controller,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          inputFormatters: widget.inputFormatters,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            labelText: '${widget.labelEn} (${widget.labelUr})',
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
            ),
            filled: true,
            fillColor: cs.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.onSurface.withOpacity(0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.accentOrange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _sectionContainer({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(12.0),
    margin: const EdgeInsets.only(bottom: 12.0),
    decoration: BoxDecoration(
      color: AppColors.lightSeaGreen.withOpacity(0.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

/// ---------- Sections ----------

class _VehicleInformationSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController numberController;
  final TextEditingController colorController;

  const _VehicleInformationSection({
    required this.nameController,
    required this.numberController,
    required this.colorController,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Vehicle Information',
          titleUr: 'گاڑی کی معلومات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Vehicle Name',
          labelUr: 'گاڑی نام',
          isRequired: true,
          controller: nameController,
        ),
        CustomInputField(
          labelEn: 'Vehicle Number',
          labelUr: 'گاڑی نمبر',
          isRequired: true,
          controller: numberController,
        ),
        CustomInputField(
          labelEn: 'Vehicle Color',
          labelUr: 'گاڑی رنگ',
          isRequired: true,
          controller: colorController,
        ),
      ],
    );
  }
}

class _ProprietorInformationSection extends StatelessWidget {
  final TextEditingController proprietorController;
  final TextEditingController generalManagerController;
  final TextEditingController managerController;
  final TextEditingController secretaryController;

  const _ProprietorInformationSection({
    required this.proprietorController,
    required this.generalManagerController,
    required this.managerController,
    required this.secretaryController,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Proprietor Information',
          titleUr: 'مالک کی معلومات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Proprietor',
          labelUr: 'مالک',
          isRequired: true,
          controller: proprietorController,
        ),
        CustomInputField(
          labelEn: 'General Manager',
          labelUr: 'جنرل منیجر',
          isRequired: true,
          controller: generalManagerController,
        ),
        CustomInputField(
          labelEn: 'Manager',
          labelUr: 'منیجر',
          isRequired: true,
          controller: managerController,
        ),
        CustomInputField(
          labelEn: 'Secretary',
          labelUr: 'سیکرٹری',
          isRequired: true,
          controller: secretaryController,
        ),
      ],
    );
  }
}

class _RouteInformationSection extends StatelessWidget {
  final TextEditingController fromController;
  final TextEditingController toController;

  const _RouteInformationSection({
    required this.fromController,
    required this.toController,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Route Information',
          titleUr: 'معلوماتِ راستہ',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'From',
          labelUr: 'سے',
          isRequired: true,
          controller: fromController,
        ),
        CustomInputField(
          labelEn: 'To',
          labelUr: 'تک',
          isRequired: true,
          controller: toController,
        ),
      ],
    );
  }
}

class _OfficeTerminalSection extends StatelessWidget {
  final TextEditingController boardingController;
  final TextEditingController arrivalController;

  const _OfficeTerminalSection({
    required this.boardingController,
    required this.arrivalController,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Office / Terminal Information',
          titleUr: 'دفتر / ٹرمینل کی معلومات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Boarding Office/Terminal',
          labelUr: 'سوار ہونے کا دفتر/اڈا',
          isRequired: true,
          controller: boardingController,
        ),
        CustomInputField(
          labelEn: 'Arrival Office/Terminal',
          labelUr: 'منزل پر اترنے کا دفتر/اڈا',
          isRequired: true,
          controller: arrivalController,
        ),
      ],
    );
  }
}

class _ScheduleDetailsSection extends StatelessWidget {
  final TextEditingController departureController;
  final TextEditingController arrivalController;
  final Function(TextEditingController) onPickDateTime;

  const _ScheduleDetailsSection({
    required this.departureController,
    required this.arrivalController,
    required this.onPickDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Schedule Details',
          titleUr: 'شیڈول کی تفصیلات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Departure Time',
          labelUr: ' روانگی کا وقت',
          isRequired: true,
          controller: departureController,
          readOnly: true,
        ),
        CustomInputField(
          labelEn: 'Arrival Time',
          labelUr: 'آمد کا وقت',
          isRequired: true,
          controller: arrivalController,
          readOnly: true,
        ),
      ],
    );
  }
}

class _SeatPricingSection extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController applicationController;
  final Service service;

  const _SeatPricingSection({
    required this.priceController,
    required this.applicationController,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Seat & Pricing Details',
          titleUr: 'نشست اور قیمت کی تفصیلات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Price Per Seat',
          labelUr: 'فی نشست قیمت',
          isRequired: true,
          controller: priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
        ),
        CustomInputField(
          labelEn: 'Application Charges',
          labelUr: 'ایپلیکیشن چارجز',
          controller: applicationController,
          readOnly: true,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            // Determine if this is a bus or van service based on capacity
            // Vans typically have 15 seats or fewer, buses have more
            final isBusService = service.capacity > 15;
            final isVanService = service.capacity <= 15;

            Widget? seatLayoutScreen;
            if (isVanService) {
              seatLayoutScreen = const VanSeatLayoutFromImagePage();
            } else if (isBusService) {
              seatLayoutScreen = const SeatLayoutConfigPage();
            }

            if (seatLayoutScreen != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => seatLayoutScreen!),
              ).then((result) {
                // Handle the result from seat layout configuration
                if (result != null && result is Map<String, dynamic>) {
                  // Update service with new seat layout data
                  // This would be handled when the service is saved
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seat layout updated')),
                  );
                }
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Unable to determine service type for seat layout',
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outline.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_seat, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.seatLayout != null
                            ? 'Seat layout configured'
                            : 'Configure seat layout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        service.seatLayout != null
                            ? 'Tap to view/modify seating layout'
                            : 'Tap to configure seating layout',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom CNIC Input Formatter
class CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 4 || i == 11) && i != text.length - 1) {
        buffer.write('-');
      }
    }
    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// Schedule Trip Dialog
class ScheduleTripDialog extends StatefulWidget {
  final String serviceId;
  final String fromLocation;
  final String toLocation;
  final int capacity;

  const ScheduleTripDialog({
    super.key,
    required this.serviceId,
    required this.fromLocation,
    required this.toLocation,
    required this.capacity,
  });

  @override
  State<ScheduleTripDialog> createState() => _ScheduleTripDialogState();
}

class _ScheduleTripDialogState extends State<ScheduleTripDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers for schedule form
  final _travelDateController = TextEditingController();
  final _departureTimeController = TextEditingController();
  final _arrivalTimeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _travelDateController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      _travelDateController.text = pickedDate.toIso8601String().split('T')[0];
    }
  }

  Future<void> _selectTime(
    TextEditingController controller,
    String title,
  ) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      controller.text = selectedDateTime.toIso8601String();
    }
  }

  Future<void> _createSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error
    });

    try {
      final apiService = ApiService();

      // Create or get route
      final routeName = '${widget.fromLocation} → ${widget.toLocation}';
      var routeId = 'route_${DateTime.now().millisecondsSinceEpoch}';

      // Try to find existing route
      final existingRoutes = await apiService.getRoutes();
      final existingRoute = existingRoutes.firstWhere(
        (route) => route['name'] == routeName,
        orElse: () => <String, dynamic>{},
      );

      if (existingRoute.isNotEmpty) {
        routeId = existingRoute['id'];
      } else {
        // Create new route
        final routeData = {
          'name': routeName,
          'from': widget.fromLocation,
          'to': widget.toLocation,
          'distance': 0.0,
          'duration': 60,
        };
        final newRoute = await apiService.createRoute(routeData);
        routeId = newRoute['id'];
      }

      // Find or create vehicle for the service
      var vehicleId = '';
      final serviceVehicles = await apiService.getServiceVehicles(
        widget.serviceId,
      );

      if (serviceVehicles.isNotEmpty) {
        // Use the first available vehicle for this service
        vehicleId = serviceVehicles.first['id'];
      } else {
        // No vehicles exist for this service - show helpful error message
        throw Exception(
          'No vehicles found for this service. Please create a vehicle first before scheduling trips.\n\n'
          'Go to: Fleet Management → Add Vehicle',
        );
      }

      final scheduleData = {
        'service_id': widget.serviceId,
        'route_id': routeId,
        'vehicle_id': vehicleId, // Now includes the vehicle ID
        'departure_time': _departureTimeController.text,
        'arrival_time': _arrivalTimeController.text,
        'travel_date': _travelDateController.text,
        'total_seats': widget.capacity,
        'status': 'scheduled',
        'notes': _notesController.text.trim(),
      };

      await apiService.createSchedule(scheduleData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip scheduled successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to schedule trip: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed header (non-scrollable)
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: cs.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Schedule New Trip',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Travel Date
                      TextFormField(
                        controller: _travelDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Travel Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _selectDate,
                          ),
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please select travel date'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Departure Time
                      TextFormField(
                        controller: _departureTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Departure Time',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(
                              _departureTimeController,
                              'Departure Time',
                            ),
                          ),
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please select departure time'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Arrival Time
                      TextFormField(
                        controller: _arrivalTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Arrival Time',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(
                              _arrivalTimeController,
                              'Arrival Time',
                            ),
                          ),
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please select arrival time'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          alignLabelWithHint: true,
                        ),
                      ),

                      // Error message display
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed footer (non-scrollable)
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                          : const Text('Schedule Trip'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
