import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import '../../../core/services/manager_data_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/schedule.dart';
import '../services/service_edit_screen.dart';
part 'manage_schedules_data.dart';
part 'manage_schedules_ui.dart';

class ManageSchedulesScreen extends StatefulWidget {
  const ManageSchedulesScreen({super.key});

  @override
  State<ManageSchedulesScreen> createState() => _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends State<ManageSchedulesScreen>
    with TickerProviderStateMixin {
  late ManageSchedulesData _data;
  late ManagerDataService _dataService;

  @override
  void initState() {
    super.initState();
    _dataService = ManagerDataService();
    _data = ManageSchedulesData(_dataService);
    _dataService.addListener(_onDataChanged);
    _initializeSchedules();
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeSchedules() async {
    await _data.loadSchedules();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshSchedules() async {
    await _initializeSchedules();
  }

  void _showCreateScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateScheduleDialog(),
    ).then((result) {
      if (result == true) {
        _refreshSchedules();
      }
    });
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
        title: const Text('Manage Schedules'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateScheduleDialog(context),
            tooltip: 'Create Schedule',
          ),
        ],
      ),
      body: _buildSchedulesUI(this),
    );
  }
}
