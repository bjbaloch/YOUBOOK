import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Data/bus_service_data.dart';
import '../Logic/bus_service_logic.dart';
import '../../../core/models/booking.dart';
import '../../../core/services/api_service.dart';

class AvailableBusesUI extends StatefulWidget {
  final BusServiceData? searchData;
  final List<Map<String, dynamic>> schedules;
  final List<Map<String, dynamic>> services;

  const AvailableBusesUI({
    super.key,
    this.searchData,
    this.schedules = const [],
    this.services = const [],
  });

  @override
  State<AvailableBusesUI> createState() => _AvailableBusesUIState();
}

class _AvailableBusesUIState extends State<AvailableBusesUI> {
  late List<BusServiceInfo> _availableBusServices;

  @override
  void initState() {
    super.initState();
    _availableBusServices = _convertServicesToBusServiceInfo(widget.services);
  }

  @override
  void didUpdateWidget(AvailableBusesUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.services != widget.services) {
      _availableBusServices = _convertServicesToBusServiceInfo(widget.services);
    }
  }

  List<BusServiceInfo> _convertServicesToBusServiceInfo(
    List<Map<String, dynamic>> services,
  ) {
    return services.map((service) {
      // Extract service information
      final serviceName = service['name']?.toString() ?? 'Bus Service';
      final routeName = service['route_name']?.toString();
      final fromLocation = service['from_location']?.toString() ?? 'Unknown';
      final toLocation = service['to_location']?.toString() ?? 'Unknown';
      final basePrice = (service['base_price'] as num?)?.toDouble() ?? 0.0;
      final features =
          (service['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final capacity = service['capacity'] ?? 50;

      return BusServiceInfo(
        id: service['id']?.toString() ?? '',
        name: serviceName,
        route: routeName ?? '$fromLocation → $toLocation',
        from: fromLocation,
        to: toLocation,
        basePrice: basePrice,
        features: features,
        capacity: capacity,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () => BusServiceLogic.handleBackPress(context),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            toolbarHeight: 45,
            backgroundColor: cs.primary,
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () =>
                  BusServiceLogic.navigateBackToBusService(context),
            ),
            centerTitle: true,
            title: Text(
              "Available Buses",
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            _searchSummary(cs),
            Expanded(
              child: _availableBusServices.isEmpty
                  ? _emptyState(cs)
                  : _busesList(cs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchSummary(ColorScheme cs) {
    if (widget.searchData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: cs.surface,
        child: Row(
          children: [
            Icon(Icons.directions_bus, color: cs.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              "All Available Buses",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_bus, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                "From: ${widget.searchData!.selectedFromLocation ?? 'Unknown'} → To: ${widget.searchData!.selectedToLocation ?? 'Unknown'}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: cs.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                widget.searchData!.departureDate != null
                    ? BusServiceLogic.formatDate(
                        widget.searchData!.departureDate!,
                      )
                    : 'No date selected',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withOpacity(0.8),
                ),
              ),
              if (widget.searchData!.selectedTripType ==
                  TripType.roundTrip) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: cs.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.searchData!.returnDate != null
                      ? "Return: ${BusServiceLogic.formatDate(widget.searchData!.returnDate!)}"
                      : 'No return date',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus,
            size: 80,
            color: cs.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No buses available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for available buses",
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _busesList(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableBusServices.length,
      itemBuilder: (context, index) {
        final busService = _availableBusServices[index];
        return _busServiceCard(busService, cs);
      },
    );
  }

  Widget _busServiceCard(BusServiceInfo busService, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToSchedules(busService),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Service Name (Bold)
              Text(
                busService.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Route
              Text(
                busService.route,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),

              // Row: Origin -> Arrow Icon -> Destination
              Row(
                children: [
                  Expanded(
                    child: Text(
                      busService.from,
                      style: TextStyle(fontSize: 16, color: cs.onSurface),
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: cs.primary, size: 20),
                  Expanded(
                    child: Text(
                      busService.to,
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 16, color: cs.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Capacity and Price
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${busService.capacity} seats',
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Text(
                    'From Rs. ${busService.basePrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Features as chips
              if (busService.features.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: busService.features.take(4).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // View Schedules Button (replaces Check Seats)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _checkSeats(busService),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("check seats"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkSeats(BusServiceInfo busService) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = ApiService();

      // Get service details to check for seat layout
      final serviceDetails = await apiService.getPublicServiceDetails(
        busService.id,
      );

      // Hide loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Check if seat layout is configured
      final seatLayout = serviceDetails['seat_layout'];
      if (seatLayout == null ||
          seatLayout['seats'] == null ||
          (seatLayout['seats'] as List).isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Seat layout not configured for this service.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Create a mock schedule info for display purposes
      final mockScheduleInfo = {
        'id': null,
        'origin': serviceDetails['from_location'] ?? busService.from,
        'destination': serviceDetails['to_location'] ?? busService.to,
        'departure_time': null,
        'service_name': busService.name,
      };

      // Since there are no schedules, all seats are available (no bookings)
      final bookedSeatIds = <String>{};

      // Navigate to seat layout display screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SeatLayoutDisplayScreen(
              serviceName: busService.name,
              serviceId: busService.id,
              seatLayout: seatLayout,
              bookedSeatIds: bookedSeatIds,
              scheduleInfo: mockScheduleInfo,
              isServiceLayoutOnly: true,
              basePrice: busService.basePrice,
            ),
          ),
        );
      }
    } catch (e) {
      // Hide loading if still showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load seat information: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToSchedules(BusServiceInfo busService) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = ApiService();
      final schedules = await apiService.getSchedulesForService(busService.id);

      // Hide loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Convert schedules to BusInfo format for display
      final busInfos = schedules.map((schedule) {
        final vehicle = schedule['vehicles'] as Map<String, dynamic>? ?? {};
        final service = schedule; // The schedule contains service info

        // Format times
        final departureTime = schedule['departure_time'];
        final arrivalTime = schedule['arrival_time'];
        String depTimeStr = 'N/A';
        if (departureTime != null) {
          try {
            final dep = DateTime.parse(departureTime);
            final hour = dep.hour > 12
                ? dep.hour - 12
                : (dep.hour == 0 ? 12 : dep.hour);
            final amPm = dep.hour >= 12 ? 'PM' : 'AM';
            depTimeStr =
                '${hour}:${dep.minute.toString().padLeft(2, '0')} $amPm';
          } catch (e) {
            depTimeStr = 'N/A';
          }
        }

        String arrTimeStr = 'N/A';
        if (arrivalTime != null) {
          try {
            final arr = DateTime.parse(arrivalTime);
            final hour = arr.hour > 12
                ? arr.hour - 12
                : (arr.hour == 0 ? 12 : arr.hour);
            final amPm = arr.hour >= 12 ? 'PM' : 'AM';
            arrTimeStr =
                '${hour}:${arr.minute.toString().padLeft(2, '0')} $amPm';
          } catch (e) {
            arrTimeStr = 'N/A';
          }
        }

        final from = schedule['origin']?.toString() ?? 'Unknown';
        final to = schedule['destination']?.toString() ?? 'Unknown';
        final features = (busService.features).toList();
        final price =
            (schedule['base_fare'] as num?)?.toInt() ??
            busService.basePrice.toInt();

        return BusInfo(
          id: schedule['id']?.toString() ?? '',
          name: busService.name,
          departureTime: depTimeStr,
          arrivalTime: arrTimeStr,
          from: from,
          to: to,
          features: features,
          price: price,
          vehicleId: schedule['vehicle_id']?.toString(),
        );
      }).toList();

      // Navigate to a schedule selection screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScheduleSelectionScreen(
              serviceName: busService.name,
              schedules: busInfos,
              vehicleType: VehicleType.bus,
            ),
          ),
        );
      }
    } catch (e) {
      // Hide loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load schedules: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class SeatLayoutDisplayScreen extends StatefulWidget {
  final String serviceName;
  final String serviceId;
  final Map<String, dynamic> seatLayout;
  final Set<String> bookedSeatIds;
  final Map<String, dynamic> scheduleInfo;
  final bool isServiceLayoutOnly;
  final double basePrice;

  const SeatLayoutDisplayScreen({
    super.key,
    required this.serviceName,
    required this.serviceId,
    required this.seatLayout,
    required this.bookedSeatIds,
    required this.scheduleInfo,
    this.isServiceLayoutOnly = false,
    required this.basePrice,
  });

  @override
  State<SeatLayoutDisplayScreen> createState() =>
      _SeatLayoutDisplayScreenState();
}

class _SeatLayoutDisplayScreenState extends State<SeatLayoutDisplayScreen> {
  final Set<String> _selectedSeatIds = {};
  final Map<String, String> _selectedSeatGenders = {}; // seatId -> gender
  String _bookingGender = 'male'; // 'male' or 'female'

  double get _totalPrice => _selectedSeatIds.length * widget.basePrice;

  bool get _canBook => _selectedSeatIds.length == 5;

  void _toggleSeatSelection(String seatId) {
    setState(() {
      if (_selectedSeatIds.contains(seatId)) {
        _selectedSeatIds.remove(seatId);
        _selectedSeatGenders.remove(seatId);
      } else {
        // Check if we've already selected 5 seats
        if (_selectedSeatIds.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only select exactly 5 seats'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Find the seat to record its gender
        final seats = widget.seatLayout['seats'] as List<dynamic>? ?? [];
        final seat = seats.firstWhere(
          (s) => s['number']?.toString() == seatId,
          orElse: () => null,
        );

        if (seat != null) {
          final seatGender = seat['gender'] as String? ?? 'general';
          _selectedSeatIds.add(seatId);
          _selectedSeatGenders[seatId] = seatGender;
        }
      }
    });
  }

  Future<void> _bookSelectedSeats() async {
    if (_selectedSeatIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one seat')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = ApiService();

      // Check if user has sufficient balance
      final wallet = await apiService.getPassengerWallet();
      final balance = (wallet['balance'] as num?)?.toDouble() ?? 0.0;

      if (balance < _totalPrice) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Insufficient Balance'),
              content: Text(
                'You need Rs. ${_totalPrice.toStringAsFixed(2)} but only have Rs. ${balance.toStringAsFixed(2)} in your wallet.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to top-up screen
                  },
                  child: const Text('Top-up Wallet'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Create booking for the service (since no schedule exists)
      final bookingResult = await apiService.createServiceBooking(
        serviceId: widget.serviceId,
        selectedSeatNumbers: _selectedSeatIds.toList(),
        totalPrice: _totalPrice,
      );

      // Hide loading
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (bookingResult != null) {
        if (context.mounted) {
          // Show success dialog
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Booking Successful!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service: ${widget.serviceName}'),
                  Text('Seats: ${_selectedSeatIds.join(', ')}'),
                  Text('Total: Rs. ${_totalPrice.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Your booking is confirmed. You will be notified when a schedule becomes available.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          // Navigate back to services list
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create booking. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          toolbarHeight: 45,
          backgroundColor: cs.primary,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            "Seat Layout - ${widget.serviceName}",
            style: TextStyle(
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service/Schedule Info Card
                  Card(
                    color: cs.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isServiceLayoutOnly
                                ? 'Service Layout'
                                : 'Next Schedule',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (widget.isServiceLayoutOnly) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: cs.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'This shows the seat layout configured for this service. All seats are currently available.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: cs.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.route, color: cs.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${widget.scheduleInfo['origin'] ?? 'Unknown'} → ${widget.scheduleInfo['destination'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: cs.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatScheduleTime(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.route, color: cs.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${widget.scheduleInfo['origin'] ?? 'Unknown'} → ${widget.scheduleInfo['destination'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender Selection Toggle
                  Card(
                    color: cs.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Preference',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      setState(() => _bookingGender = 'male'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _bookingGender == 'male'
                                        ? cs.primary
                                        : Colors.grey[300],
                                    foregroundColor: _bookingGender == 'male'
                                        ? cs.onPrimary
                                        : Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.man,
                                        size: 20,
                                        color: _bookingGender == 'male'
                                            ? cs.onPrimary
                                            : Colors.black,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Book Male Seats'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      setState(() => _bookingGender = 'female'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _bookingGender == 'female'
                                        ? cs.primary
                                        : Colors.grey[300],
                                    foregroundColor: _bookingGender == 'female'
                                        ? cs.onPrimary
                                        : Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.woman,
                                        size: 20,
                                        color: _bookingGender == 'female'
                                            ? cs.onPrimary
                                            : Colors.black,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Book Female Seats'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You must select exactly 5 seats of your chosen gender.',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Legend
                  Card(
                    color: cs.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Legend',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _legendItem(Colors.grey[300]!, 'Available'),
                              _legendItem(Colors.pink, 'Female Reserved'),
                              _legendItem(Colors.pink[300]!, 'Female Selected'),
                              _legendItem(
                                const Color(0xFF20B2AA),
                                'Male Reserved',
                              ),
                              _legendItem(
                                const Color(0xFF90EE90),
                                'Male Selected',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Seat Layout
                  Card(
                    color: cs.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Seat Layout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSeatGrid(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Booking Section
          if (_selectedSeatIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Seats: ${_selectedSeatIds.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            'Seats: ${_selectedSeatIds.join(', ')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Rs. ${_totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _bookSelectedSeats,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book Selected Seats',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black26),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Color _getSeatColor(
    Map<String, dynamic> seat,
    bool isBooked,
    bool isSelected,
  ) {
    final seatGender = seat['gender'] as String? ?? 'general';
    final seatId = seat['number']?.toString();

    if (isBooked) {
      // Booked seats show their gender-specific colors, enhanced when preference matches
      if (seatGender == 'female') {
        return _bookingGender == 'female'
            ? Colors
                  .pink // Enhanced pink for female preference
            : Colors.pink.withOpacity(0.8); // Standard female reserved color
      } else {
        return _bookingGender == 'male'
            ? const Color(0xFF20B2AA) // Enhanced for male preference
            : const Color(
                0xFF20B2AA,
              ).withOpacity(0.8); // Standard male reserved color
      }
    } else if (isSelected && seatId != null) {
      // Selected seats show color based on their recorded gender
      final selectedSeatGender = _selectedSeatGenders[seatId] ?? seatGender;
      if (selectedSeatGender == 'female') {
        return _bookingGender == 'female'
            ? Colors.pink[300]! // Enhanced lighter pink for female preference
            : Colors.pink[300]!.withOpacity(
                0.8,
              ); // Standard female selected color
      } else {
        return _bookingGender == 'male'
            ? const Color(
                0xFF90EE90,
              ) // Enhanced light green for male preference
            : const Color(
                0xFF90EE90,
              ).withOpacity(0.8); // Standard male selected color
      }
    } else {
      // Available seats - show prominent gender indication when preference matches
      if (_bookingGender == 'female' && seatGender == 'female') {
        return Colors.pink[200]!; // Prominent pink for available female seats
      } else if (_bookingGender == 'male' && seatGender == 'male') {
        return const Color(
          0xFF87CEEB,
        ); // Prominent blue for available male seats
      }
      return Colors.grey[300]!; // Standard gray for other available seats
    }
  }

  bool _canSelectSeat(
    Map<String, dynamic> seat,
    int seatIndex,
    List<dynamic> allSeats,
  ) {
    final seatGender = seat['gender'] as String? ?? 'general';
    final isBooked = widget.bookedSeatIds.contains(seat['number']?.toString());
    final isSelected = _selectedSeatIds.contains(seat['number']?.toString());

    if (isBooked || isSelected) return false;

    // Only allow seats of the selected gender
    if (seatGender != _bookingGender && seatGender != 'general') return false;

    // Check if we've already selected 5 seats
    if (_selectedSeatIds.length >= 5) return false;

    // Apply gender-based restrictions for adjacent seats
    // Rule: If a seat is selected/reserved by female, males cannot book next to her
    // Rule: If a seat is selected/reserved by male, females CAN book next to him

    final adjacentIndices = _getAdjacentSeatIndices(seatIndex, allSeats.length);

    for (final adjIndex in adjacentIndices) {
      if (adjIndex >= 0 && adjIndex < allSeats.length) {
        final adjSeat = allSeats[adjIndex];
        final adjGender = adjSeat['gender'] as String? ?? 'general';
        final isAdjBooked = widget.bookedSeatIds.contains(
          adjSeat['number']?.toString(),
        );
        final isAdjSelected = _selectedSeatIds.contains(
          adjSeat['number']?.toString(),
        );

        if (isAdjBooked || isAdjSelected) {
          // If adjacent seat is occupied by female, males cannot select
          if (adjGender == 'female' && _bookingGender == 'male') {
            return false;
          }
          // If adjacent seat is occupied by male, females CAN select (no restriction)
          // This allows females to book next to males
        }
      }
    }

    return true;
  }

  List<int> _getAdjacentSeatIndices(int currentIndex, int totalSeats) {
    final adjacent = <int>[];

    // Left adjacent
    if (currentIndex > 0) {
      adjacent.add(currentIndex - 1);
    }

    // Right adjacent
    if (currentIndex < totalSeats - 1) {
      adjacent.add(currentIndex + 1);
    }

    return adjacent;
  }

  Widget _buildSeatGrid() {
    final seats = widget.seatLayout['seats'] as List<dynamic>? ?? [];
    final rows = widget.seatLayout['rows'] as int? ?? 0;
    final columns = widget.seatLayout['columns'] as int? ?? 0;
    final useLastRowOverride =
        widget.seatLayout['useLastRowOverride'] as bool? ?? false;
    final lastRowColumns =
        widget.seatLayout['lastRowColumns'] as int? ?? columns;
    final driverSide = widget.seatLayout['driverSide'] as String? ?? 'Right';

    final List<Widget> rowWidgets = [];
    int seatIndex = 0;

    // Driver seat
    rowWidgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: driverSide == 'Left'
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: driverSide == 'Left' ? 35 : 0,
                right: driverSide == 'Right' ? 35 : 0,
              ),
              child: Icon(
                Icons.event_seat,
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );

    for (int r = 0; r < rows; r++) {
      final bool isLastRow = useLastRowOverride && r == rows - 1;
      final int currentCols = isLastRow ? lastRowColumns : columns;

      final List<Widget> seatRow = [];
      for (int c = currentCols - 1; c >= 0; c--) {
        if (seatIndex >= seats.length) break;

        final seat = seats[seatIndex] as Map<String, dynamic>;
        final seatNumber = seat['number'] as int? ?? 0;
        final isRemoved = seat['removed'] as bool? ?? false;

        if (!isRemoved) {
          final seatId = seatNumber.toString();
          final isBooked = widget.bookedSeatIds.contains(seatId);
          final isSelected = _selectedSeatIds.contains(seatId);
          final canSelect =
              !isBooked &&
              !isSelected &&
              _canSelectSeat(seat, seatIndex, seats);

          seatRow.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: canSelect ? () => _toggleSeatSelection(seatId) : null,
                child: Container(
                  width: 40,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getSeatColor(seat, isBooked, isSelected),
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    seatNumber.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isBooked || isSelected
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        seatIndex++;
      }

      if (seatRow.isNotEmpty) {
        rowWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: seatRow,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowWidgets,
    );
  }

  String _formatScheduleTime() {
    final departureTime = widget.scheduleInfo['departure_time'];
    if (departureTime == null) return 'Time not available';

    try {
      final dep = DateTime.parse(departureTime);
      final hour = dep.hour > 12
          ? dep.hour - 12
          : (dep.hour == 0 ? 12 : dep.hour);
      final amPm = dep.hour >= 12 ? 'PM' : 'AM';
      final date = '${dep.day}/${dep.month}/${dep.year}';
      return '$date ${hour}:${dep.minute.toString().padLeft(2, '0')} $amPm';
    } catch (e) {
      return 'Time not available';
    }
  }
}

class BusServiceInfo {
  final String id;
  final String name;
  final String route;
  final String from;
  final String to;
  final double basePrice;
  final List<String> features;
  final int capacity;

  const BusServiceInfo({
    required this.id,
    required this.name,
    required this.route,
    required this.from,
    required this.to,
    required this.basePrice,
    required this.features,
    required this.capacity,
  });
}

class BusInfo {
  final String id;
  final String name;
  final String departureTime;
  final String arrivalTime;
  final String from;
  final String to;
  final List<String> features;
  final int price;
  final String? vehicleId;

  const BusInfo({
    required this.id,
    required this.name,
    required this.departureTime,
    required this.arrivalTime,
    required this.from,
    required this.to,
    required this.features,
    required this.price,
    this.vehicleId,
  });
}

class ScheduleSelectionScreen extends StatefulWidget {
  final String serviceName;
  final List<BusInfo> schedules;
  final VehicleType vehicleType;

  const ScheduleSelectionScreen({
    super.key,
    required this.serviceName,
    required this.schedules,
    required this.vehicleType,
  });

  @override
  State<ScheduleSelectionScreen> createState() =>
      _ScheduleSelectionScreenState();
}

class _ScheduleSelectionScreenState extends State<ScheduleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          toolbarHeight: 45,
          backgroundColor: cs.primary,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            "Available Schedules",
            style: TextStyle(
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: widget.schedules.isEmpty
          ? _emptyState(cs)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.schedules.length,
              itemBuilder: (context, index) {
                final schedule = widget.schedules[index];
                return _scheduleCard(schedule, cs);
              },
            ),
    );
  }

  Widget _emptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 80, color: cs.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            "No schedules available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for available schedules",
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleCard(BusInfo schedule, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to actual seat selection when SeatSelectionLogic is implemented
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seat selection coming soon!')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Name
              Text(
                schedule.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Route
              Row(
                children: [
                  Expanded(
                    child: Text(
                      schedule.from,
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: cs.primary, size: 16),
                  Expanded(
                    child: Text(
                      schedule.to,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Times and Price
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${schedule.departureTime} - ${schedule.arrivalTime}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    'Rs. ${schedule.price}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),

              // Features
              if (schedule.features.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: schedule.features.take(3).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to actual seat selection when SeatSelectionLogic is implemented
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Seat selection coming soon!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Select Seats"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
