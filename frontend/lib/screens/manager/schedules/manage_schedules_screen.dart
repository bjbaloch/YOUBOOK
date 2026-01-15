import 'dart:async';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _data = ManageSchedulesData();
    _initializeSchedules();
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
      ),
      body: _buildSchedulesUI(this),
    );
  }
}
