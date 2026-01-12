import 'dart:async';
import 'package:flutter/material.dart';
part 'manager_services_data.dart';
part 'manager_services_ui.dart';

class ManagerServicesScreen extends StatefulWidget {
  const ManagerServicesScreen({super.key});

  @override
  State<ManagerServicesScreen> createState() => _ManagerServicesScreenState();
}

class _ManagerServicesScreenState extends State<ManagerServicesScreen>
    with TickerProviderStateMixin {
  late ManagerServicesData _data;

  @override
  void initState() {
    super.initState();
    _data = ManagerServicesData();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _data.loadServices();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _addService(Service service) async {
    setState(() {
      _data.addService(service);
    });
    // TODO: Save to backend
  }

  Future<void> _updateService(Service service) async {
    setState(() {
      _data.updateService(service);
    });
    // TODO: Save to backend
  }

  Future<void> _deleteService(String serviceId) async {
    setState(() {
      _data.deleteService(serviceId);
    });
    // TODO: Save to backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddServiceDialog(context),
            tooltip: 'Add Service',
          ),
        ],
      ),
      body: _buildServicesUI(this),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(context),
        tooltip: 'Add New Service',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddServiceDialog(
        onAddService: (service) {
          Navigator.of(context).pop();
          _addService(service);
        },
      ),
    );
  }
}
