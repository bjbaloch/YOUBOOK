import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Data/bus_service_data.dart';
import '../Logic/bus_service_logic.dart';
import '../../booking/Logic/seat_selection_logic.dart';
import '../../../core/models/booking.dart';

class AvailableBusesUI extends StatefulWidget {
  final BusServiceData searchData;

  const AvailableBusesUI({
    super.key,
    required this.searchData,
  });

  @override
  State<AvailableBusesUI> createState() => _AvailableBusesUIState();
}

class _AvailableBusesUIState extends State<AvailableBusesUI> {
  // Mock bus data for demonstration - in real app this would come from API
  final List<BusInfo> _availableBuses = [
    BusInfo(
      id: 'bus_001',
      companyName: 'Daewoo Express',
      departureTime: '08:00',
      arrivalTime: '14:00',
      duration: '6h 0m',
      fare: 2500,
      availableSeats: 35,
      totalSeats: 40,
      busType: 'Luxury Coach',
    ),
    BusInfo(
      id: 'bus_002',
      companyName: 'Faisal Movers',
      departureTime: '10:30',
      arrivalTime: '16:30',
      duration: '6h 0m',
      fare: 2200,
      availableSeats: 28,
      totalSeats: 40,
      busType: 'AC Sleeper',
    ),
    BusInfo(
      id: 'bus_003',
      companyName: 'Skyways',
      departureTime: '14:00',
      arrivalTime: '20:00',
      duration: '6h 0m',
      fare: 2000,
      availableSeats: 42,
      totalSeats: 45,
      busType: 'Economy',
    ),
    BusInfo(
      id: 'bus_004',
      companyName: 'Kohistan Express',
      departureTime: '16:30',
      arrivalTime: '22:30',
      duration: '6h 0m',
      fare: 1800,
      availableSeats: 15,
      totalSeats: 40,
      busType: 'Standard',
    ),
  ];

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
              onPressed: () => BusServiceLogic.navigateBackToBusService(context),
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
              child: _availableBuses.isEmpty
                  ? _emptyState(cs)
                  : _busesList(cs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchSummary(ColorScheme cs) {
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
                "${widget.searchData.selectedFromCity} → ${widget.searchData.selectedToCity}",
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
              Icon(Icons.calendar_today, size: 16, color: cs.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(
                BusServiceLogic.formatDate(widget.searchData.departureDate!),
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withOpacity(0.8),
                ),
              ),
              if (widget.searchData.selectedTripType == TripType.roundTrip) ...[
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: cs.onSurface.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  "Return: ${BusServiceLogic.formatDate(widget.searchData.returnDate!)}",
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
            "Try changing your search criteria",
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => BusServiceLogic.navigateBackToBusService(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Modify Search"),
          ),
        ],
      ),
    );
  }

  Widget _busesList(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableBuses.length,
      itemBuilder: (context, index) {
        final bus = _availableBuses[index];
        return _busCard(bus, cs);
      },
    );
  }

  Widget _busCard(BusInfo bus, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          SeatSelectionLogic.navigateToSeatSelection(
            context,
            bus.id,
            VehicleType.bus,
            bus.fare.toDouble(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_bus, color: cs.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bus.companyName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          bus.busType,
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: bus.availableSeats > 10 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${bus.availableSeats} seats left",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bus.departureTime,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          "Departure",
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          bus.duration,
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: cs.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          bus.arrivalTime,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          "Arrival",
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    "Rs. ${bus.fare}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      SeatSelectionLogic.navigateToSeatSelection(
                        context,
                        bus.id,
                        VehicleType.bus,
                        bus.fare.toDouble(),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BusInfo {
  final String id;
  final String companyName;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int fare;
  final int availableSeats;
  final int totalSeats;
  final String busType;

  const BusInfo({
    required this.id,
    required this.companyName,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.fare,
    required this.availableSeats,
    required this.totalSeats,
    required this.busType,
  });
}
