import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/snackbar_utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.serviceType});

  final String serviceType;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController(
    text: '1',
  );

  DateTime? _selectedDate;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _passengersController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _search() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.serviceType == AppConstants.serviceTransport &&
        _selectedDate == null) {
      SnackBarUtils.showSnackBar(
        context,
        'Please select a travel date',
        type: SnackBarType.other,
      );
      return;
    }

    // Navigate to search results (Placeholder - would integrate with search_results_screen.dart)
    SnackBarUtils.showSnackBar(
      context,
      'Search functionality will be implemented',
      type: SnackBarType.other,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.serviceType == AppConstants.serviceTransport
        ? 'Search Buses/Trains'
        : widget.serviceType == AppConstants.serviceAccommodation
        ? 'Find Hotels'
        : 'Find Rentals';

    return Scaffold(
      appBar: AppBar(title: Text(title), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // From Location
              TextFormField(
                controller: _fromController,
                decoration: InputDecoration(
                  labelText:
                      widget.serviceType == AppConstants.serviceAccommodation
                      ? 'City'
                      : 'From Location',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // To Location (only for transport and rental)
              if (widget.serviceType == AppConstants.serviceTransport ||
                  widget.serviceType == AppConstants.serviceRental)
                TextFormField(
                  controller: _toController,
                  decoration: InputDecoration(
                    labelText: 'To Location',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter destination';
                    }
                    return null;
                  },
                ),

              if (widget.serviceType == AppConstants.serviceTransport ||
                  widget.serviceType == AppConstants.serviceRental)
                const SizedBox(height: 16),

              // Date Selector (only for transport)
              if (widget.serviceType == AppConstants.serviceTransport)
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Travel Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 16),

              // Passengers (only for transport)
              if (widget.serviceType == AppConstants.serviceTransport)
                TextFormField(
                  controller: _passengersController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Passengers',
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of passengers';
                    }
                    final count = int.tryParse(value);
                    if (count == null || count < 1 || count > 5) {
                      return 'Please enter 1-5 passengers';
                    }
                    return null;
                  },
                ),

              // Additional fields for hotels
              if (widget.serviceType == AppConstants.serviceAccommodation) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Check-in',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Check-out',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Rooms',
                    prefixIcon: const Icon(Icons.hotel),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

              // Additional fields for car rental
              if (widget.serviceType == AppConstants.serviceRental) ...[
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Days',
                    prefixIcon: const Icon(Icons.schedule),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Search Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Search',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick options
              if (widget.serviceType == AppConstants.serviceTransport) ...[
                const Text(
                  'Quick Search',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickSearchChip('Lahore → Karachi'),
                    _QuickSearchChip('Islamabad → Lahore'),
                    _QuickSearchChip('Karachi → Lahore'),
                    _QuickSearchChip('Peshawar → Islamabad'),
                  ],
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickSearchChip extends StatelessWidget {
  final String route;

  const _QuickSearchChip(this.route);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Auto-fill the route
        final parts = route.split(' → ');
        if (parts.length == 2) {
          // This would update the form fields
          SnackBarUtils.showSnackBar(
            context,
            'Selected: $route',
            type: SnackBarType.other,
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        label: Text(route, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.greyShade100,
      ),
    );
  }
}
