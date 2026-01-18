import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import '../../../core/services/manager_data_service.dart';
import '../../../core/models/vehicle.dart';
import '../services/service_edit_screen.dart';
part 'track_vehicles_data.dart';
part 'track_vehicles_ui.dart';

class TrackVehiclesScreen extends StatefulWidget {
  const TrackVehiclesScreen({super.key});

  @override
  State<TrackVehiclesScreen> createState() => _TrackVehiclesScreenState();
}

class _TrackVehiclesScreenState extends State<TrackVehiclesScreen>
    with TickerProviderStateMixin {
  late TrackVehiclesData _data;
  late ManagerDataService _dataService;

  @override
  void initState() {
    super.initState();
    _dataService = ManagerDataService();
    _data = TrackVehiclesData(_dataService);
    _dataService.addListener(_onDataChanged);
    _initializeVehicles();
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

  Future<void> _initializeVehicles() async {
    await _data.loadVehicles();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshVehicles() async {
    await _initializeVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Track Services'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _buildVehiclesUI(this),
    );
  }
}
