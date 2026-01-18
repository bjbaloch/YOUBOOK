import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youbook/core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/manager_data_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/vehicle.dart';
import '../../../features/add_service/UI/add_service_ui.dart';
import 'service_model.dart';
import 'service_edit_screen.dart';
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
  late ManagerDataService _dataService;

  @override
  void initState() {
    super.initState();
    _dataService = ManagerDataService();
    _data = ManagerServicesData(_dataService);
    // Remove listener to prevent setState during build
    _initializeServices();
  }

  @override
  void dispose() {
    // No listener to remove
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _data.loadServices();
    if (mounted) {
      setState(() {});
    }
  }

  void _refreshServices() {
    _initializeServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Manage Services'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _buildServicesUI(this),
    );
  }
}
