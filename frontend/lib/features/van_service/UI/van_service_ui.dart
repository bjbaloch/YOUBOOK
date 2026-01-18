import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/api_service.dart';
import '../Data/van_service_data.dart';
import '../Logic/van_service_logic.dart';

class VanServiceUI extends StatefulWidget {
  const VanServiceUI({super.key});

  @override
  State<VanServiceUI> createState() => _VanServiceUIState();
}

class _VanServiceUIState extends State<VanServiceUI> {
  late final VanServiceData _data;
  List<RouteModel> _availableRoutes = [];
  List<String> _availableOrigins = [];
  List<String> _availableDestinations = [];
  bool _isLoadingRoutes = true;
  bool _isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _data = VanServiceData();
    _loadRoutes();
    _loadLocations();
  }

  Future<void> _loadRoutes() async {
    try {
      final routes = await VanServiceData.getAvailableRoutes();
      if (mounted) {
        setState(() {
          _availableRoutes = routes;
          _isLoadingRoutes = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading routes: $e');
      if (mounted) {
        setState(() {
          _isLoadingRoutes = false;
        });
      }
    }
  }

  Future<void> _loadLocations() async {
    try {
      final apiService = ApiService();

      // Get locations directly from routes (simpler approach)
      final routeLocations = await apiService.getRouteLocationsByType(
        serviceType: 'van',
      );
      final locations = [
        ...routeLocations['origins']!,
        ...routeLocations['destinations']!,
      ].toSet().toList();

      if (locations.isNotEmpty) {
        if (mounted) {
          setState(() {
            _availableOrigins = locations;
            _availableDestinations = locations;
            _isLoadingLocations = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Error loading route locations: $e');
    }

    // Final fallback - set some default locations if no routes found or error occurred
    if (mounted) {
      setState(() {
        _availableOrigins = ['Lahore', 'Karachi', 'Islamabad', 'Rawalpindi'];
        _availableDestinations = [
          'Lahore',
          'Karachi',
          'Islamabad',
          'Rawalpindi',
        ];
        _isLoadingLocations = false;
      });
    }
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
              onPressed: () => VanServiceLogic.navigateBackToHome(context),
            ),
            centerTitle: true,
            title: Text(
              "Van Service",
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tripTypeSelector(cs),
              const SizedBox(height: 16),
              _mainBookingCard(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tripTypeSelector(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Trip Type",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _tripTypeButton(
                  cs,
                  "One Way",
                  _data.selectedTripType == TripType.oneWay,
                  () =>
                      setState(() => _data.selectedTripType = TripType.oneWay),
                ),
              ),
              Expanded(
                child: _tripTypeButton(
                  cs,
                  "Round Trip (Upcoming)",
                  _data.selectedTripType == TripType.roundTrip,
                  () => setState(
                    () => _data.selectedTripType = TripType.roundTrip,
                  ),
                  isDisabled: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tripTypeButton(
    ColorScheme cs,
    String label,
    bool isSelected,
    VoidCallback onTap, {
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Round trip feature is coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : (isDisabled ? cs.surface.withOpacity(0.5) : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? cs.onPrimary
                : (isDisabled ? cs.onSurface.withOpacity(0.5) : cs.onSurface),
            fontWeight: FontWeight.w500,
            fontStyle: isDisabled ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  Widget _routeSelector(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Route",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<RouteModel>(
          value: _data.selectedRoute,
          decoration: InputDecoration(
            labelText: "Choose Route",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: cs.surface,
          ),
          items: _availableRoutes.map((route) {
            return DropdownMenuItem<RouteModel>(
              value: route,
              child: Text(route.displayName),
            );
          }).toList(),
          onChanged: (route) => setState(() {
            _data.selectedRoute = route;
            if (route != null) {
              _data.selectedFromLocation = route.fromCity;
              _data.selectedToLocation = route.toCity;
            } else {
              _data.selectedFromLocation = null;
              _data.selectedToLocation = null;
            }
          }),
        ),
        if (_data.selectedRoute != null) ...[
          const SizedBox(height: 8),
          Text(
            "Selected Route: ${_data.selectedRoute!.displayName}",
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _dateSelector(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Travel Dates",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _datePicker(
                cs,
                "Departure",
                _data.departureDate,
                (date) => setState(() => _data.departureDate = date),
              ),
            ),
            if (_data.selectedTripType == TripType.roundTrip) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _datePicker(
                  cs,
                  "Return",
                  _data.returnDate,
                  (date) => setState(() => _data.returnDate = date),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _datePicker(
    ColorScheme cs,
    String label,
    DateTime? selectedDate,
    ValueChanged<DateTime?> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final maxDate = now.add(
          const Duration(days: 20),
        ); // Vans available for 20 days only
        final date = await VanServiceLogic.selectDate(
          context,
          selectedDate ?? now,
          now,
          maxDate,
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: cs.surface,
          suffixIcon: Icon(Icons.calendar_today, color: cs.primary),
        ),
        child: Text(
          selectedDate != null
              ? VanServiceLogic.formatDate(selectedDate)
              : "Select date",
          style: TextStyle(
            color: selectedDate != null
                ? cs.onSurface
                : cs.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _mainBookingCard(ColorScheme cs) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _routeSelector(cs),
            const SizedBox(height: 20),
            _dateSelector(cs),
            const SizedBox(height: 24),
            _searchButton(cs),
          ],
        ),
      ),
    );
  }

  Widget _searchButton(ColorScheme cs) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _data.isValidForSearch
            ? () => VanServiceLogic.navigateToAvailableVans(context, _data)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          "Show Available Vans",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
