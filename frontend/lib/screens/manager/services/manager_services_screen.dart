import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/auth_provider.dart';
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _buildServicesUI(this),
    );
  }
}
