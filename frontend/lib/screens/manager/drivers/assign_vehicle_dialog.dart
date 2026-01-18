import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/manager_data_service.dart';
import '../../../core/models/driver.dart';

class AssignVehicleDialog extends StatefulWidget {
  const AssignVehicleDialog({super.key, required this.driver});

  final Driver driver;

  @override
  State<AssignVehicleDialog> createState() => _AssignVehicleDialogState();
}

class _AssignVehicleDialogState extends State<AssignVehicleDialog> {
  final _apiService = ApiService();
  final _dataService = ManagerDataService();
  List<Map<String, dynamic>> _availableVehicles = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedVehicleId;

  @override
  void initState() {
    super.initState();
    _loadAvailableVehicles();
  }

  Future<void> _loadAvailableVehicles() async {
    try {
      final vehicles = await _apiService.getManagerVehicles();

      // Filter out vehicles that are already assigned to other drivers
      final availableVehicles = vehicles.where((vehicle) {
        final currentDriverId = vehicle['current_driver_id'];
        return currentDriverId == null ||
               currentDriverId == widget.driver.id ||
               currentDriverId.isEmpty;
      }).toList();

      setState(() {
        _availableVehicles = availableVehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _assignVehicle() async {
    if (_selectedVehicleId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Update vehicle with assigned driver using ManagerDataService to update cache
      await _dataService.updateVehicle(_selectedVehicleId!, {
        'current_driver_id': widget.driver.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle assigned to ${widget.driver.fullName} successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to refresh the list
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _unassignVehicle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Find the currently assigned vehicle
      final assignedVehicle = _availableVehicles.firstWhere(
        (vehicle) => vehicle['current_driver_id'] == widget.driver.id,
        orElse: () => <String, dynamic>{},
      );

      if (assignedVehicle.isNotEmpty) {
        // Update vehicle to unassign driver using ManagerDataService to update cache
        await _dataService.updateVehicle(assignedVehicle['id'], {
          'current_driver_id': null,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vehicle unassigned from ${widget.driver.fullName} successfully!')),
          );
          Navigator.of(context).pop(true); // Return true to refresh the list
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.directions_car, color: cs.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign Vehicle',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          'Assign or unassign vehicle for ${widget.driver.fullName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: cs.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (_isLoading) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ] else if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Current assignment status
                if (widget.driver.isOnDuty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_car, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Currently assigned to: ${widget.driver.currentVehicleNumber}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton(
                      onPressed: _unassignVehicle,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Unassign Vehicle',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                ] else ...[
                  // Vehicle selection
                  Text(
                    'Available Vehicles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_availableVehicles.isEmpty) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.no_crash,
                              size: 48,
                              color: cs.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No available vehicles',
                              style: TextStyle(
                                fontSize: 16,
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableVehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = _availableVehicles[index];
                          final isSelected = _selectedVehicleId == vehicle['id'];

                          return RadioListTile<String>(
                            title: Text(
                              '${vehicle['registration_number'] ?? vehicle['vehicle_number']} (${vehicle['make']} ${vehicle['model']})',
                              style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              'Capacity: ${vehicle['capacity']} seats',
                              style: TextStyle(
                                color: cs.onSurface.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                            value: vehicle['id'],
                            groupValue: _selectedVehicleId,
                            onChanged: (value) {
                              setState(() {
                                _selectedVehicleId = value;
                              });
                            },
                            activeColor: cs.primary,
                            dense: true,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _selectedVehicleId != null ? _assignVehicle : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Assign Vehicle',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
