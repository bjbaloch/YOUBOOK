import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/location_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/logout_dialog.dart';

part 'driver_data.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with WidgetsBindingObserver {
  late DriverData _data;
  Timer? _syncTimer;
  Timer? _connectivityTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _data = DriverData();
    _initializeDriverMode();
    _setupConnectivityMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivityTimer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeDriverMode() async {
    await _data.loadManifest();
    await _data.checkTripStatus();
    _startPeriodicSync();
  }

  void _setupConnectivityMonitoring() {
    _connectivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkConnectivity();
    });
    _checkConnectivity(); // Initial check
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (mounted && _data.isOnline != isOnline) {
        setState(() {
          _data.isOnline = isOnline;
        });
        if (isOnline) {
          _syncPendingCheckIns();
        }
      }
    } catch (e) {
      if (mounted && _data.isOnline) {
        setState(() {
          _data.isOnline = false;
        });
      }
    }
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_data.isOnline && _data.hasPendingSync) {
        _syncPendingCheckIns();
      }
    });
  }

  Future<void> _syncPendingCheckIns() async {
    try {
      await _data.syncCheckIns();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  Future<void> _startTrip() async {
    try {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.startTracking();

      setState(() {
        _data.isTripActive = true;
        _data.tripStartTime = DateTime.now();
      });

      // TODO: Notify server that trip has started
      await _data.startTripTracking();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start trip: $e')),
        );
      }
    }
  }

  Future<void> _endTrip() async {
    try {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.stopTracking();

      setState(() {
        _data.isTripActive = false;
        _data.tripEndTime = DateTime.now();
      });

      // TODO: Notify server that trip has ended
      await _data.endTripTracking();
      await _syncPendingCheckIns();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end trip: $e')),
        );
      }
    }
  }

  Future<void> _checkInPassenger(String passengerId) async {
    setState(() {
      _data.checkInPassenger(passengerId);
    });

    if (_data.isOnline) {
      await _syncPendingCheckIns();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: cs.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: cs.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: _buildDriverAppBar(),
        body: SafeArea(
          child: _data.manifest == null
              ? _buildNoTripView()
              : _buildTripView(),
        ),
        bottomNavigationBar: _buildDriverBottomBar(),
      ),
    );
  }

  PreferredSizeWidget _buildDriverAppBar() {
    final cs = Theme.of(context).colorScheme;

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        color: cs.primary,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Status Indicators
                Expanded(
                  child: Row(
                    children: [
                      _buildStatusIndicator(
                        icon: _data.isOnline ? Icons.wifi : Icons.wifi_off,
                        color: _data.isOnline ? Colors.green : Colors.red,
                        label: _data.isOnline ? 'Online' : 'Offline',
                      ),
                      const SizedBox(width: 16),
                      if (_data.isTripActive)
                        _buildStatusIndicator(
                          icon: Icons.gps_fixed,
                          color: Colors.blue,
                          label: 'GPS Active',
                        ),
                      const SizedBox(width: 16),
                      _buildStatusIndicator(
                        icon: Icons.people,
                        color: cs.onPrimary,
                        label: '${_data.checkedInCount}/${_data.totalPassengers}',
                      ),
                    ],
                  ),
                ),
                // Emergency Button
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Emergency contact
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Emergency - Coming Soon')),
                    );
                  },
                  icon: const Icon(Icons.emergency, color: Colors.white),
                  label: const Text('Emergency'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNoTripView() {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus,
              size: 80,
              color: cs.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Trip',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will receive trip assignments from your manager.\nManifest will be downloaded automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                LogoutDialog.show(context, currentScreen: 'driver');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
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

  Widget _buildTripView() {
    return Column(
      children: [
        // Trip Status Card
        _buildTripStatusCard(),
        // Passenger Manifest
        Expanded(
          child: _buildPassengerManifest(),
        ),
      ],
    );
  }

  Widget _buildTripStatusCard() {
    final cs = Theme.of(context).colorScheme;
    final trip = _data.manifest!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _data.isTripActive ? Colors.green : cs.outline.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_bus,
                color: cs.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trip.routeName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _data.isTripActive
                      ? Colors.green.withOpacity(0.1)
                      : cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _data.isTripActive ? Colors.green : cs.primary,
                  ),
                ),
                child: Text(
                  _data.isTripActive ? 'TRIP ACTIVE' : 'READY TO START',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _data.isTripActive ? Colors.green : cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTripInfo(
                  icon: Icons.schedule,
                  label: 'Departure',
                  value: trip.departureTime,
                ),
              ),
              Expanded(
                child: _buildTripInfo(
                  icon: Icons.location_on,
                  label: 'From',
                  value: trip.fromLocation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTripInfo(
                  icon: Icons.access_time,
                  label: 'Duration',
                  value: trip.estimatedDuration,
                ),
              ),
              Expanded(
                child: _buildTripInfo(
                  icon: Icons.location_on,
                  label: 'To',
                  value: trip.toLocation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: cs.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerManifest() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Passenger Manifest',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _data.manifest!.passengers.length,
            itemBuilder: (context, index) {
              final passenger = _data.manifest!.passengers[index];
              return _buildPassengerCard(passenger);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerCard(Passenger passenger) {
    final cs = Theme.of(context).colorScheme;
    final isCheckedIn = passenger.isCheckedIn;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Passenger Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: isCheckedIn
                  ? Colors.green.withOpacity(0.1)
                  : cs.primary.withOpacity(0.1),
              child: Icon(
                isCheckedIn ? Icons.check_circle : Icons.person,
                color: isCheckedIn ? Colors.green : cs.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Passenger Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    passenger.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Seat ${passenger.seatNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (passenger.phoneNumber != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      passenger.phoneNumber!,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Check-in Button
            ElevatedButton(
              onPressed: passenger.isCheckedIn
                  ? null
                  : () => _checkInPassenger(passenger.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckedIn ? Colors.green : cs.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isCheckedIn ? 'Checked In' : 'Check In',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverBottomBar() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          if (!_data.isTripActive) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startTrip,
                icon: const Icon(Icons.play_arrow, size: 24),
                label: const Text(
                  'START TRIP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _endTrip,
                icon: const Icon(Icons.stop, size: 24),
                label: const Text(
                  'END TRIP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
