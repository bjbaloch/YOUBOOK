import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Data/bus_service_data.dart';
import '../Logic/bus_service_logic.dart';

class BusServiceUI extends StatefulWidget {
  const BusServiceUI({super.key});

  @override
  State<BusServiceUI> createState() => _BusServiceUIState();
}

class _BusServiceUIState extends State<BusServiceUI> {
  final BusServiceData _data = BusServiceData();

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
              onPressed: () => BusServiceLogic.navigateBackToHome(context),
            ),
            centerTitle: true,
            title: Text(
              "Bus Service",
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
                  () => setState(() => _data.selectedTripType = TripType.oneWay),
                ),
              ),
              Expanded(
                child: _tripTypeButton(
                  cs,
                  "Round Trip",
                  _data.selectedTripType == TripType.roundTrip,
                  () => setState(() => _data.selectedTripType = TripType.roundTrip),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tripTypeButton(ColorScheme cs, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w500,
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
          "Route",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _citySelector(
          cs,
          "From",
          _data.selectedFromCity,
          (city) => setState(() => _data.selectedFromCity = city),
        ),
        const SizedBox(height: 12),
        _citySelector(
          cs,
          "To",
          _data.selectedToCity,
          (city) => setState(() => _data.selectedToCity = city),
        ),
      ],
    );
  }

  Widget _citySelector(ColorScheme cs, String label, String? selectedCity, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedCity,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: cs.surface,
      ),
      items: BusServiceData.availableCities.map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dateSelector(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Travel Dates",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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

  Widget _datePicker(ColorScheme cs, String label, DateTime? selectedDate, ValueChanged<DateTime?> onChanged) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final maxDate = now.add(const Duration(days: 20)); // Buses available for 20 days only
        final date = await BusServiceLogic.selectDate(
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: cs.surface,
          suffixIcon: Icon(Icons.calendar_today, color: cs.primary),
        ),
        child: Text(
          selectedDate != null
              ? BusServiceLogic.formatDate(selectedDate)
              : "Select date",
          style: TextStyle(
            color: selectedDate != null ? cs.onSurface : cs.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _mainBookingCard(ColorScheme cs) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
            ? () => BusServiceLogic.navigateToAvailableBuses(context, _data)
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
          "Show Available Buses",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
