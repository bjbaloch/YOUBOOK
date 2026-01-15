import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/schedule.dart';
part 'passenger_manifests_data.dart';
part 'passenger_manifests_ui.dart';

class PassengerManifestsScreen extends StatefulWidget {
  const PassengerManifestsScreen({super.key});

  @override
  State<PassengerManifestsScreen> createState() => _PassengerManifestsScreenState();
}

class _PassengerManifestsScreenState extends State<PassengerManifestsScreen>
    with TickerProviderStateMixin {
  late PassengerManifestsData _data;

  @override
  void initState() {
    super.initState();
    _data = PassengerManifestsData();
    _initializeManifests();
  }

  Future<void> _initializeManifests() async {
    await _data.loadSchedules();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshManifests() async {
    await _initializeManifests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Passenger Manifests'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _buildManifestsUI(this),
    );
  }
}
