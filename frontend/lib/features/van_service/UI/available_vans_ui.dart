import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Data/van_service_data.dart';
import '../Logic/van_service_logic.dart';
import '../../booking/Logic/seat_selection_logic.dart';
import '../../../core/models/booking.dart';

class AvailableVansUI extends StatefulWidget {
  final VanServiceData searchData;

  const AvailableVansUI({
    super.key,
    required this.searchData,
  });

  @override
  State<AvailableVansUI> createState() => _AvailableVansUIState();
}

class _AvailableVansUIState extends State<AvailableVansUI> {
  // Mock van data for demonstration - in real app this would come from API
  final List<VanInfo> _availableVans = [
    VanInfo(
      id: 'van_001',
      companyName: 'City Van Service',
      departureTime: '07:00',
      arrivalTime: '13:00',
      duration: '6h 0m',
      fare: 1800,
      availableSeats: 12,
      totalSeats: 15,
      vanType: '15-Seater AC',
    ),
    VanInfo(
      id: 'van_002',
      companyName: 'Mountain Vans',
      departureTime: '09:30',
      arrivalTime: '15:30',
      duration: '6h 0m',
      fare: 1600,
      availableSeats: 8,
      totalSeats: 15,
      vanType: '15-Seater Standard',
    ),
    VanInfo(
      id: 'van_003',
      companyName: 'Express Vans',
      departureTime: '12:00',
      arrivalTime: '18:00',
      duration: '6h 0m',
      fare: 1400,
      availableSeats: 15,
      totalSeats: 15,
      vanType: '15-Seater Economy',
    ),
    VanInfo(
      id: 'van_004',
      companyName: 'Premium Vans',
      departureTime: '15:30',
      arrivalTime: '21:30',
      duration: '6h 0m',
      fare: 2000,
      availableSeats: 6,
      totalSeats: 15,
      vanType: '15-Seater Luxury',
    ),
  ];

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
              onPressed: () => VanServiceLogic.navigateBackToVanService(context),
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
              child: _availableVans.isEmpty
                  ? _emptyState(cs)
                  : _vansList(cs),
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
              Icon(Icons.airport_shuttle, color: cs.primary, size: 20),
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
                VanServiceLogic.formatDate(widget.searchData.departureDate!),
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
                  "Return: ${VanServiceLogic.formatDate(widget.searchData.returnDate!)}",
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
            "Try changing your search criteria",
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => VanServiceLogic.navigateBackToVanService(context),
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

  Widget _vansList(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableVans.length,
      itemBuilder: (context, index) {
        final van = _availableVans[index];
        return _vanCard(van, cs);
      },
    );
  }

  Widget _vanCard(VanInfo van, ColorScheme cs) {
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
            van.id,
            VehicleType.van,
            van.fare.toDouble(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.airport_shuttle, color: cs.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          van.companyName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          van.vanType,
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
                      color: van.availableSeats > 10 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${van.availableSeats} seats left",
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
                          van.departureTime,
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
                          van.duration,
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
                          van.arrivalTime,
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
                    "Rs. ${van.fare}",
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
                        van.id,
                        VehicleType.van,
                        van.fare.toDouble(),
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

class VanInfo {
  final String id;
  final String companyName;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int fare;
  final int availableSeats;
  final int totalSeats;
  final String vanType;

  const VanInfo({
    required this.id,
    required this.companyName,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.fare,
    required this.availableSeats,
    required this.totalSeats,
    required this.vanType,
  });
}
