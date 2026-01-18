import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Data/van_service_data.dart';
import '../Logic/van_service_logic.dart';
import '../../../core/models/booking.dart';
import '../../../core/services/api_service.dart';

class AvailableVansUI extends StatefulWidget {
  final VanServiceData? searchData;
  final List<Map<String, dynamic>> schedules;
  final List<Map<String, dynamic>> services;

  const AvailableVansUI({
    super.key,
    this.searchData,
    this.schedules = const [],
    this.services = const [],
  });

  @override
  State<AvailableVansUI> createState() => _AvailableVansUIState();
}

class _AvailableVansUIState extends State<AvailableVansUI> {
  late List<VanServiceInfo> _availableVanServices;

  @override
  void initState() {
    super.initState();
    _availableVanServices = _convertServicesToVanServiceInfo(widget.services);
  }

  @override
  void didUpdateWidget(AvailableVansUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.services != widget.services) {
      _availableVanServices = _convertServicesToVanServiceInfo(widget.services);
    }
  }

  List<VanServiceInfo> _convertServicesToVanServiceInfo(
    List<Map<String, dynamic>> services,
  ) {
    return services.map((service) {
      // Extract service information
      final serviceName = service['name']?.toString() ?? 'Van Service';
      final routeName = service['route_name']?.toString();
      final fromLocation = service['from_location']?.toString() ?? 'Unknown';
      final toLocation = service['to_location']?.toString() ?? 'Unknown';
      final basePrice = (service['base_price'] as num?)?.toDouble() ?? 0.0;
      final features =
          (service['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final capacity = service['capacity'] ?? 15;

      return VanServiceInfo(
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
      onWillPop: () => VanServiceLogic.handleBackPress(context),
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
                  VanServiceLogic.navigateBackToVanService(context),
            ),
            centerTitle: true,
            title: Text(
              "Available Vans",
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
              child: _availableVanServices.isEmpty
                  ? _emptyState(cs)
                  : _vansList(cs),
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
            Icon(Icons.airport_shuttle, color: cs.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              "All Available Vans",
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
              Icon(Icons.airport_shuttle, color: cs.primary, size: 20),
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
                    ? VanServiceLogic.formatDate(
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
                      ? "Return: ${VanServiceLogic.formatDate(widget.searchData!.returnDate!)}"
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
            Icons.airport_shuttle,
            size: 80,
            color: cs.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No vans available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for available vans",
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vansList(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableVanServices.length,
      itemBuilder: (context, index) {
        final vanService = _availableVanServices[index];
        return _vanServiceCard(vanService, cs);
      },
    );
  }

  Widget _vanServiceCard(VanServiceInfo vanService, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToSchedules(vanService),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Service Name (Bold)
              Text(
                vanService.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Route
              Text(
                vanService.route,
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
                      vanService.from,
                      style: TextStyle(fontSize: 16, color: cs.onSurface),
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: cs.primary, size: 20),
                  Expanded(
                    child: Text(
                      vanService.to,
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
                      '${vanService.capacity} seats',
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Text(
                    'From Rs. ${vanService.basePrice.toStringAsFixed(0)}',
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
              if (vanService.features.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: vanService.features.take(4).map((feature) {
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

              // Check Seats Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _checkSeats(vanService),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Check Seats"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkSeats(VanServiceInfo vanService) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = ApiService();

      // Get service details to check for seat layout
      final serviceDetails = await apiService.getPublicServiceDetails(vanService.id);

      // Hide loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Check if seat layout is configured
      final seatLayout = serviceDetails['seat_layout'];
      if (seatLayout == null || seatLayout['seats'] == null || (seatLayout['seats'] as List).isEmpty) {
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

      // Create a mock schedule info for display purposes (like bus system)
      final mockScheduleInfo = {
        'id': null,
        'origin': serviceDetails['from_location'] ?? vanService.from,
        'destination': serviceDetails['to_location'] ?? vanService.to,
        'departure_time': null,
        'service_name': vanService.name,
      };

      // Since there are no schedules, all seats are available (no bookings)
      final bookedSeatIds = <String>{};

      // Navigate to seat layout display screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SeatLayoutDisplayScreen(
              serviceName: vanService.name,
              serviceId: vanService.id,
              seatLayout: seatLayout,
              bookedSeatIds: bookedSeatIds,
              scheduleInfo: mockScheduleInfo,
              isServiceLayoutOnly: true, // Like bus system
              basePrice: vanService.basePrice,
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

  Future<void> _navigateToSchedules(VanServiceInfo vanService) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = ApiService();
      final schedules = await apiService.getSchedulesForService(vanService.id);

      // Hide loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Convert schedules to VanInfo format for display
      final vanInfos = schedules.map((schedule) {
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
        final features = (vanService.features).toList();
        final price =
            (schedule['base_fare'] as num?)?.toInt() ??
            vanService.basePrice.toInt();

        return VanInfo(
          id: schedule['id']?.toString() ?? '',
          name: vanService.name,
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
              serviceName: vanService.name,
              schedules: vanInfos,
              vehicleType: VehicleType.van,
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
  final String? scheduleId;
  final double basePrice;
  final bool isServiceLayoutOnly;

  const SeatLayoutDisplayScreen({
    super.key,
    required this.serviceName,
    required this.serviceId,
    required this.seatLayout,
    required this.bookedSeatIds,
    required this.scheduleInfo,
    this.scheduleId,
    required this.basePrice,
    this.isServiceLayoutOnly = false,
  });

  @override
  State<SeatLayoutDisplayScreen> createState() => _SeatLayoutDisplayScreenState();
}

class _SeatLayoutDisplayScreenState extends State<SeatLayoutDisplayScreen> {
  final Set<String> _selectedSeatIds = {};
  final Map<String, String> _selectedSeatGenders = {}; // seatId -> gender
  String _bookingGender = 'male'; // 'male' or 'female'

  // Van-specific: lower seat limit than bus
  int get _maxSeats => 3; // Vans allow max 3 seats vs bus's 5

  double get _totalPrice => _selectedSeatIds.length * widget.basePrice;

  bool get _canBook => _selectedSeatIds.length == _maxSeats;

  void _toggleSeatSelection(String seatId) {
    setState(() {
      if (_selectedSeatIds.contains(seatId)) {
        _selectedSeatIds.remove(seatId);
        _selectedSeatGenders.remove(seatId);
      } else {
        // Check if we've already selected max seats
        if (_selectedSeatIds.length >= _maxSeats) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can only select exactly $_maxSeats seats'),
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

      // Choose booking method based on whether we have a schedule or not
      final bookingResult;
      if (widget.scheduleId != null) {
        // Schedule-based booking (when schedules exist)
        bookingResult = await apiService.createBooking(
          scheduleId: widget.scheduleId!,
          seatIds: _selectedSeatIds.toList(),
          totalPrice: _totalPrice,
        );
      } else {
        // Service-level booking (when no schedules exist, like bus system)
        bookingResult = await apiService.createServiceBooking(
          serviceId: widget.serviceId,
          selectedSeatNumbers: _selectedSeatIds.toList(),
          totalPrice: _totalPrice,
        );
      }

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
                    'Your van booking is confirmed.',
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
                  // Schedule Info Card
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
                            'Schedule Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule, color: cs.primary, size: 20),
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
                            'You must select exactly $_maxSeats seats of your chosen gender.',
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

    // Check if we've already selected max seats
    if (_selectedSeatIds.length >= _maxSeats) return false;

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
    final cs = Theme.of(context).colorScheme;

    if (seats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No seat layout available'),
      );
    }

    // Van-specific layout: Fixed 15-seater arrangement
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Driver seat indicator
        Padding(
          padding: const EdgeInsets.only(bottom: 20, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'ڈرائیور',
                style: TextStyle(fontSize: 14, color: cs.primary),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.event_seat_outlined,
                color: cs.primary,
                size: 28,
              ),
            ],
          ),
        ),

        // Row 1: Seats 0,1 | Aisle | Seats 3,4
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVanSeatTile(seats, 0),
            _buildVanSeatTile(seats, 1),
            SizedBox(width: 32), // Aisle
            _buildVanSeatTile(seats, 3),
            _buildVanSeatTile(seats, 4),
          ],
        ),

        // Row 2: Seat 2 (wide) | Aisle | Seats 6,7
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVanSeatTile(seats, 2, isWide: true),
            SizedBox(width: 32), // Aisle
            _buildVanSeatTile(seats, 6),
            _buildVanSeatTile(seats, 7),
          ],
        ),

        // Row 3: Seat 5 (wide) | Aisle | Seats 9,10
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVanSeatTile(seats, 5, isWide: true),
            SizedBox(width: 32), // Aisle
            _buildVanSeatTile(seats, 9),
            _buildVanSeatTile(seats, 10),
          ],
        ),

        // Row 4: Seat 8 (wide) | Aisle | Empty, Empty
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVanSeatTile(seats, 8, isWide: true),
            SizedBox(width: 32), // Aisle
            _buildEmptySeatSpace(),
            _buildEmptySeatSpace(),
          ],
        ),

        // Row 5: Seats 11,12 | Aisle | Seats 13,14
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVanSeatTile(seats, 11),
            _buildVanSeatTile(seats, 12),
            SizedBox(width: 32), // Aisle
            _buildVanSeatTile(seats, 13),
            _buildVanSeatTile(seats, 14),
          ],
        ),
      ],
    );
  }

  Widget _buildVanSeatTile(List<dynamic> seats, int seatIndex, {bool isWide = false}) {
    if (seatIndex >= seats.length) {
      return _buildEmptySeatSpace(isWide: isWide);
    }

    final seat = seats[seatIndex] as Map<String, dynamic>;
    final seatNumber = seat['number'] as int? ?? 0;
    final seatId = seatNumber.toString();
    final isRemoved = seat['removed'] as bool? ?? false;
    final cs = Theme.of(context).colorScheme;

    if (isRemoved) {
      return _buildEmptySeatSpace(isWide: isWide);
    }

    final isBooked = widget.bookedSeatIds.contains(seatId);
    final isSelected = _selectedSeatIds.contains(seatId);
    final canSelect = !isBooked && !isSelected && _canSelectSeat(seat, seatIndex, seats);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: canSelect ? () => _toggleSeatSelection(seatId) : null,
        child: Container(
          width: isWide ? 88 : 40, // Wide seats span 2 normal widths + padding
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
              color: isBooked || isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySeatSpace({bool isWide = false}) {
    return SizedBox(
      width: isWide ? 88 : 40,
      height: 32,
    );
  }

  String _formatScheduleTime() {
    final departureTime = widget.scheduleInfo['departure_time'];
    if (departureTime == null) return 'Time not available';

    try {
      final dep = DateTime.parse(departureTime);
      final hour = dep.hour > 12 ? dep.hour - 12 : (dep.hour == 0 ? 12 : dep.hour);
      final amPm = dep.hour >= 12 ? 'PM' : 'AM';
      final date = '${dep.day}/${dep.month}/${dep.year}';
      return '$date ${hour}:${dep.minute.toString().padLeft(2, '0')} $amPm';
    } catch (e) {
      return 'Time not available';
    }
  }
}

class VanServiceInfo {
  final String id;
  final String name;
  final String route;
  final String from;
  final String to;
  final double basePrice;
  final List<String> features;
  final int capacity;

  const VanServiceInfo({
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

class VanInfo {
  final String id;
  final String name;
  final String departureTime;
  final String arrivalTime;
  final String from;
  final String to;
  final List<String> features;
  final int price;
  final String? vehicleId;

  const VanInfo({
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
  final List<VanInfo> schedules;
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

  Widget _scheduleCard(VanInfo schedule, ColorScheme cs) {
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
                      const SnackBar(content: Text('Seat selection coming soon!')),
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
