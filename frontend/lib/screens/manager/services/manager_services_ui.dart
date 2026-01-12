part of 'manager_services_screen.dart';

Widget _buildServicesUI(_ManagerServicesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  if (state._data.isLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  return RefreshIndicator(
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
  );
}

Widget _buildServicesSummary(_ManagerServicesScreenState state) {
  final cs = Theme.of(state.context).colorScheme;
  final activeServices = state._data.getActiveServices();
  final totalRevenue = state._data.getTotalRevenue();

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
            icon: Icons.business,
            title: 'Total Services',
            value: '${state._data.services.length}',
            color: cs.primary,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.check_circle,
            title: 'Active',
            value: '${activeServices.length}',
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.attach_money,
            title: 'Revenue',
            value: 'PKR ${totalRevenue.toStringAsFixed(0)}',
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
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
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
            'Create your first service to get started',
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => state._showAddServiceDialog(state.context),
            icon: const Icon(Icons.add),
            label: const Text('Add First Service'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
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
                  value: service.type.toString().split('.').last.toUpperCase(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Features
          if (service.features.isNotEmpty) ...[
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
              children: service.features.map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
          ],

          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditServiceDialog(state, service),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showDeleteConfirmation(state, service),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
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
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
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

void _showEditServiceDialog(_ManagerServicesScreenState state, Service service) {
  showDialog(
    context: state.context,
    builder: (context) => _AddServiceDialog(
      service: service,
      onAddService: (updatedService) {
        Navigator.of(context).pop();
        state._updateService(updatedService);
      },
    ),
  );
}

void _showDeleteConfirmation(_ManagerServicesScreenState state, Service service) {
  showDialog(
    context: state.context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Service'),
      content: Text('Are you sure you want to delete "${service.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            state._deleteService(service.id);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

class _AddServiceDialog extends StatefulWidget {
  final Service? service;
  final Function(Service) onAddService;

  const _AddServiceDialog({
    this.service,
    required this.onAddService,
  });

  @override
  State<_AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<_AddServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _routeController = TextEditingController();
  final _featuresController = TextEditingController();

  ServiceType _selectedType = ServiceType.standard;
  final List<String> _features = [];

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description;
      _priceController.text = widget.service!.basePrice.toString();
      _capacityController.text = widget.service!.capacity.toString();
      _routeController.text = widget.service!.route;
      _selectedType = widget.service!.type;
      _features.addAll(widget.service!.features);
    }
  }

  void _addFeature() {
    if (_featuresController.text.isNotEmpty) {
      setState(() {
        _features.add(_featuresController.text.trim());
        _featuresController.clear();
      });
    }
  }

  void _removeFeature(int index) {
    setState(() {
      _features.removeAt(index);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final service = widget.service != null
          ? Service(
              id: widget.service!.id,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              type: _selectedType,
              status: widget.service!.status,
              basePrice: double.parse(_priceController.text),
              capacity: int.parse(_capacityController.text),
              route: _routeController.text.trim(),
              features: _features,
              createdAt: widget.service!.createdAt,
              updatedAt: DateTime.now(),
            )
          : Service.create(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              type: _selectedType,
              basePrice: double.parse(_priceController.text),
              capacity: int.parse(_capacityController.text),
              route: _routeController.text.trim(),
              features: _features,
            );

      widget.onAddService(service);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.service != null ? 'Edit Service' : 'Add New Service',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Service Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                      hintText: 'e.g., Islamabad to Lahore Standard',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter service name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief description of the service',
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Type and Route Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ServiceType>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Service Type',
                          ),
                          items: ServiceType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.toString().split('.').last.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _routeController,
                          decoration: const InputDecoration(
                            labelText: 'Route',
                            hintText: 'e.g., Islamabad → Lahore',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter route';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price and Capacity Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Base Price (PKR)',
                            hintText: '2500',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter price';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price <= 0) {
                              return 'Invalid price';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _capacityController,
                          decoration: const InputDecoration(
                            labelText: 'Capacity',
                            hintText: '12',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter capacity';
                            }
                            final capacity = int.tryParse(value);
                            if (capacity == null || capacity <= 0) {
                              return 'Invalid capacity';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Features
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _featuresController,
                          decoration: const InputDecoration(
                            hintText: 'Add feature (e.g., AC, WiFi)',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _addFeature(),
                        ),
                      ),
                      IconButton(
                        onPressed: _addFeature,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _features.asMap().entries.map((entry) {
                      final index = entry.key;
                      final feature = entry.value;
                      return Chip(
                        label: Text(feature),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeFeature(index),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                        ),
                        child: Text(widget.service != null ? 'Update' : 'Create'),
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
