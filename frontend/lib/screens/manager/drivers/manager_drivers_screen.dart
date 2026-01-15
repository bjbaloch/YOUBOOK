import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/driver.dart';
import 'add_driver_screen.dart';
part 'manager_drivers_data.dart';
part 'manager_drivers_ui.dart';

class ManagerDriversScreen extends StatefulWidget {
  const ManagerDriversScreen({super.key});

  @override
  State<ManagerDriversScreen> createState() => _ManagerDriversScreenState();
}

class _ManagerDriversScreenState extends State<ManagerDriversScreen>
    with TickerProviderStateMixin {
  late ManagerDriversData _data;

  @override
  void initState() {
    super.initState();
    _data = ManagerDriversData();
    _initializeDrivers();
  }

  Future<void> _initializeDrivers() async {
    await _data.loadDrivers();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshDrivers() async {
    await _initializeDrivers();
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
        title: const Text('Manager Drivers'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _buildDriversUI(this),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDriverDialog(context),
        tooltip: 'Add Driver',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDriverDialog(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddDriverScreen()));

    // If driver was created successfully, refresh the list
    if (result == true && mounted) {
      await _refreshDrivers();
    }
  }
}
