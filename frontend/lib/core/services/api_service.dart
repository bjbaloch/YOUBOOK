import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final supabase = Supabase.instance.client;

  // Manager services endpoints
  Future<List<Map<String, dynamic>>> getManagerServices() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('services')
        .select('*')
        .eq('manager_id', user.id)
        .neq('name', 'Default Service') // Filter out default services
        .order('created_at', ascending: false); // Newest services first

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getServiceById(String serviceId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('services')
        .select('*')
        .eq('id', serviceId)
        .eq('manager_id', user.id) // Ensure user owns the service
        .single();

    return response;
  }

  Future<Map<String, dynamic>> createService(
    Map<String, dynamic> serviceData,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Map form data keys to database column names
      final vehicleName = serviceData['vanName'] ?? serviceData['busName'];
      final vehicleNumber =
          serviceData['vanNumber'] ?? serviceData['busNumber'];
      final vehicleColor = serviceData['vanColor'] ?? serviceData['busColor'];

      final servicePayload = {
        'name': vehicleName, // vanName/busName
        'description':
            'Transport service from ${serviceData['from']} to ${serviceData['to']}',
        'type': serviceData['type'],
        'status': 'active',
        'manager_id': user.id,
        'base_price':
            double.tryParse(serviceData['pricePerSeat']?.toString() ?? '0') ??
            0.0,
        'capacity':
            serviceData['seatLayoutData']?['totalSeats'] ??
            50, // Use actual seat count from layout
        'route_name': '${serviceData['from']} → ${serviceData['to']}',
        'features': ['AC', 'WiFi'], // Default features
        'is_active': true,
        'commission_rate': 0.0, // Default commission
        // Van/Bus specific fields
        'vehicle_number': vehicleNumber,
        'vehicle_color': vehicleColor,

        'proprietor': serviceData['proprietor'],
        'general_manager': serviceData['generalManager'],
        'manager': serviceData['manager'],
        'secretary': serviceData['secretary'],
        'from_location': serviceData['from'],
        'to_location': serviceData['to'],
        'boarding_office': serviceData['boardingOffice'],
        'arrival_office': serviceData['arrivalOffice'],
        'departure_time': serviceData['departureTime'],
        'arrival_time': serviceData['arrivalTime'],
        'application_charges':
            double.tryParse(
              serviceData['applicationCharges']?.toString() ?? '0',
            ) ??
            0.0,
        'seat_layout': serviceData['seatLayoutData'],
        'is_seat_layout_configured':
            serviceData['isSeatLayoutConfigured'] ?? false,
      };

      final response = await supabase
          .from('services')
          .insert(servicePayload)
          .select()
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateService(
    String serviceId,
    Map<String, dynamic> serviceData,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final servicePayload = {
        'name': serviceData['name'],
        'description': serviceData['description'],
        'type': serviceData['type'],
        'status': serviceData['status'] ?? 'active',
        'base_price': serviceData['basePrice'],
        'capacity': serviceData['capacity'],
        'route_name': serviceData['route'],
        'features': serviceData['features'] ?? [],
        'updated_at': DateTime.now().toIso8601String(),

        // Include proprietor/office fields
        'vehicle_number': serviceData['vehicle_number'],
        'vehicle_color': serviceData['vehicle_color'],

        'proprietor': serviceData['proprietor'],
        'general_manager': serviceData['general_manager'],
        'manager': serviceData['manager'],
        'secretary': serviceData['secretary'],
        'from_location': serviceData['from_location'],
        'to_location': serviceData['to_location'],
        'boarding_office': serviceData['boarding_office'],
        'arrival_office': serviceData['arrival_office'],
        'departure_time': serviceData['departure_time'],
        'arrival_time': serviceData['arrival_time'],
        'application_charges': serviceData['application_charges'],
        'seat_layout': serviceData['seat_layout'],
        'is_seat_layout_configured': serviceData['is_seat_layout_configured'],
      };

      final response = await supabase
          .from('services')
          .update(servicePayload)
          .eq('id', serviceId)
          .eq('manager_id', user.id) // Ensure user owns the service
          .select()
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await supabase
          .from('services')
          .delete()
          .eq('id', serviceId)
          .eq('manager_id', user.id); // Ensure user owns the service
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getManagerWallet() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await supabase
          .from('wallets')
          .select('*')
          .eq('user_id', user.id)
          .single();

      return response;
    } catch (e) {
      // If no wallet exists, return a default wallet structure
      return {
        'id': '',
        'user_id': user.id,
        'balance': 0.0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<List<Map<String, dynamic>>> getManagerTransactions() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final wallet = await getManagerWallet();
    final walletId = wallet['id'];

    // If wallet doesn't exist (empty ID), return empty list
    if (walletId == null || walletId.isEmpty) {
      return [];
    }

    final response = await supabase
        .from('wallet_transactions')
        .select('*')
        .eq('wallet_id', walletId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Manager schedules endpoints
  Future<List<Map<String, dynamic>>> getManagerSchedules() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Fixed: Reference manager through service relationship
      final response = await supabase
          .from('schedules')
          .select(
            '*, routes(*), vehicles(*, services(*)), drivers(*, profiles(*))',
          )
          .eq('vehicles.services.manager_id', user.id)
          .order('departure_time', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback: Get schedules with simpler relationships
      final response = await supabase
          .from('schedules')
          .select('*, routes(*), vehicles(*, services(*))')
          .eq('vehicles.services.manager_id', user.id)
          .order('departure_time', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    }
  }

  // Manager drivers endpoints
  Future<List<Map<String, dynamic>>> getManagerDrivers() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Fixed: Use company_id instead of manager_id to match database schema
      final response = await supabase
          .from('drivers')
          .select('*, profiles(*)')
          .eq('company_id', user.id);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback: Get drivers without profile joins if relationship doesn't exist
      final response = await supabase
          .from('drivers')
          .select('*')
          .eq('company_id', user.id);

      return List<Map<String, dynamic>>.from(response);
    }
  }

  Future<Map<String, dynamic>> createDriver(
    Map<String, dynamic> driverData,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Generate a temporary password for the driver
      final tempPassword =
          'TempPass123!'; // In production, generate secure random password

      // Step 1: Create Supabase auth user
      final authResponse = await supabase.auth.admin.createUser(
        AdminUserAttributes(
          email: driverData['email'],
          password: tempPassword,
          emailConfirm: true, // Auto-confirm email
          userMetadata: {
            'role': 'driver',
            'full_name': driverData['name'],
            'phone_number': driverData['phone'],
          },
        ),
      );

      final authUserId = authResponse.user?.id;
      if (authUserId == null) {
        throw Exception('Failed to create auth user');
      }

      // Step 2: Insert driver record
      final driverPayload = {
        'company_id': user.id, // Link to current manager
        'auth_user_id': authUserId,
        'email': driverData['email'],
        'name': driverData['name'],
        'phone': driverData['phone'],
        'license_number': driverData['license_number'],
        'current_status': 'Idle', // Default status
      };

      final driverResponse = await supabase
          .from('drivers')
          .insert(driverPayload)
          .select()
          .single();

      return driverResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Manager vehicles endpoints
  Future<List<Map<String, dynamic>>> getManagerVehicles() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Fixed: Reference manager through service relationship
      final response = await supabase
          .from('vehicles')
          .select('*, services(*)')
          .eq('services.manager_id', user.id);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback: Get vehicles with direct manager reference
      final response = await supabase
          .from('vehicles')
          .select('*')
          .eq('manager_id', user.id);

      return List<Map<String, dynamic>>.from(response);
    }
  }

  // Get vehicles for a specific service
  Future<List<Map<String, dynamic>>> getServiceVehicles(String serviceId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('vehicles')
        .select('*')
        .eq('service_id', serviceId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createVehicle(
    Map<String, dynamic> vehicleData,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Prepare vehicle data with proper service association
      final serviceId = vehicleData['service_id'];
      final vehicleNumber =
          vehicleData['busNumber'] ?? vehicleData['vanNumber'] ?? 'DEFAULT-${DateTime.now().millisecondsSinceEpoch}';
      final vehiclePayload = {
        'service_id': serviceId, // Associate with service for RLS policy
        'manager_id': user.id, // Required for RLS policy compliance
        'registration_number': vehicleNumber,
        'vehicle_number': vehicleNumber,
        'type': vehicleData['type'] ?? 'bus',
        'make': vehicleData['busName'] ?? vehicleData['vanName'] ?? 'Default Vehicle',
        'model': vehicleData['busName'] ?? vehicleData['vanName'] ?? 'Default Vehicle',
        'capacity': vehicleData['seatLayoutData']?['totalSeats'] ?? 50,
        'year': DateTime.now().year,
        'status': 'active',
        'fuel_type': 'diesel',
        'is_active': true,
        'seat_layout': vehicleData['seatLayoutData'] ?? {
          'totalSeats': vehicleData['seatLayoutData']?['totalSeats'] ?? 50,
          'configured': true,
        },
      };

      final response = await supabase
          .from('vehicles')
          .insert(vehiclePayload)
          .select()
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Passenger manifests (bookings for a specific schedule)
  Future<List<Map<String, dynamic>>> getPassengerManifests(
    String scheduleId,
  ) async {
    try {
      // Fixed: Reference profiles table instead of passengers
      final response = await supabase
          .from('bookings')
          .select('*, profiles(*), booking_seats(*)')
          .eq('schedule_id', scheduleId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback: Get bookings without profile joins if relationship doesn't exist
      final response = await supabase
          .from('bookings')
          .select('*, booking_seats(*)')
          .eq('schedule_id', scheduleId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    }
  }

  // Passenger endpoints
  Future<List<Map<String, dynamic>>> getPassengerBookings() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('bookings')
        .select('*, schedules(*, vehicles(*, services(*)), routes(*))')
        .eq('passenger_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getPassengerWallet() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('wallets')
        .select('*')
        .eq('user_id', user.id)
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getPassengerTransactions() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('wallet_transactions')
        .select('*')
        .eq('wallet_id', (await getPassengerWallet())['id'])
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getPassengerPendingTransactions() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('wallet_transactions')
        .select('*')
        .eq('wallet_id', (await getPassengerWallet())['id'])
        .eq('type', 'credit')
        .or('reference_id.is.null')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Additional utility methods for bookings
  Future<Map<String, dynamic>?> createBooking({
    required String scheduleId,
    required List<String> seatIds,
    required double totalPrice,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Create booking
      final bookingData = {
        'passenger_id': user.id,
        'schedule_id': scheduleId,
        'total_price': totalPrice,
        'travel_date': DateTime.now().toIso8601String().split(
          'T',
        )[0], // Today's date as default
      };

      final bookingResponse = await supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      final bookingId = bookingResponse['id'];

      // Create booking seats
      final seatData = seatIds
          .map((seatId) => {'booking_id': bookingId, 'seat_id': seatId})
          .toList();

      await supabase.from('booking_seats').insert(seatData);

      return bookingResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Get available schedules
  Future<List<Map<String, dynamic>>> getAvailableSchedules({
    String? fromLocation,
    String? toLocation,
    DateTime? travelDate,
  }) async {
    var query = supabase
        .from('schedules')
        .select('*, routes(*), vehicles(*, services(*))')
        .eq('status', 'scheduled')
        .gt('available_seats', 0);

    if (fromLocation != null && toLocation != null) {
      // This would require a more complex query to match routes
      // For now, return all available schedules
    }

    if (travelDate != null) {
      final dateStr = travelDate.toIso8601String().split('T')[0];
      query = query.eq('travel_date', dateStr);
    }

    final response = await query.order('departure_time', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // Get wallet balance
  Future<double> getWalletBalance() async {
    final wallet = await getPassengerWallet();
    return (wallet['balance'] as num?)?.toDouble() ?? 0.0;
  }

  // Add money to wallet (simulate top-up)
  Future<bool> addMoneyToWallet(double amount, {String? description}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Get current wallet
      final wallet = await getPassengerWallet();
      final walletId = wallet['id'];
      final currentBalance = (wallet['balance'] as num).toDouble();

      // Update wallet balance
      await supabase
          .from('wallets')
          .update({
            'balance': currentBalance + amount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', walletId);

      // Create transaction record
      await supabase.from('wallet_transactions').insert({
        'wallet_id': walletId,
        'amount': amount,
        'type': 'credit',
        'description': description ?? 'Wallet top-up',
      });

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Schedule CRUD operations
  Future<Map<String, dynamic>> createSchedule(
    Map<String, dynamic> scheduleData,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final schedulePayload = {
        'service_id': scheduleData['service_id'],
        'route_id': scheduleData['route_id'],
        'vehicle_id': scheduleData['vehicle_id'] ?? null,
        'assigned_driver_id': scheduleData['driver_id'] ?? null,
        'departure_time': scheduleData['departure_time'],
        'arrival_time': scheduleData['arrival_time'],
        'travel_date': scheduleData['travel_date'],
        'total_seats': scheduleData['total_seats'],
        'status': scheduleData['status'] ?? 'scheduled',
        'boarding_points': scheduleData['boarding_points'] ?? [],
        'notes': scheduleData['notes'] ?? '',
      };

      final response = await supabase
          .from('schedules')
          .insert(schedulePayload)
          .select()
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSchedule(
    String scheduleId,
    Map<String, dynamic> scheduleData,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final schedulePayload = {
        'route_id': scheduleData['route_id'],
        'vehicle_id': scheduleData['vehicle_id'] ?? null,
        'assigned_driver_id': scheduleData['driver_id'] ?? null,
        'departure_time': scheduleData['departure_time'],
        'arrival_time': scheduleData['arrival_time'],
        'travel_date': scheduleData['travel_date'],
        'total_seats': scheduleData['total_seats'],
        'status': scheduleData['status'] ?? 'scheduled',
        'boarding_points': scheduleData['boarding_points'] ?? [],
        'notes': scheduleData['notes'] ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('schedules')
          .update(schedulePayload)
          .eq('id', scheduleId)
          .eq(
            'service_id',
            scheduleData['service_id'],
          ) // Ensure user owns the service
          .select()
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await supabase
          .from('schedules')
          .delete()
          .eq('id', scheduleId)
          .eq('services.manager_id', user.id); // Ensure user owns the service
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getScheduleById(String scheduleId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('schedules')
        .select('*, routes(*), vehicles(*), services(*), profiles(*)')
        .eq('id', scheduleId)
        .eq('services.manager_id', user.id) // Ensure user owns the service
        .single();

    return response;
  }

  // Routes operations
  Future<List<Map<String, dynamic>>> getRoutes() async {
    final response = await supabase
        .from('routes')
        .select('*')
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createRoute(
    Map<String, dynamic> routeData,
  ) async {
    final routePayload = {
      'name': routeData['name'],
      'start_location': {
        'address': routeData['from'],
        'city': routeData['from'],
        'province': routeData['from'],
        'latitude': 0.0,
        'longitude': 0.0,
      },
      'end_location': {
        'address': routeData['to'],
        'city': routeData['to'],
        'province': routeData['to'],
        'latitude': 0.0,
        'longitude': 0.0,
      },
      'distance_km': routeData['distance'] ?? 0.0,
      'estimated_duration_minutes': routeData['duration'] ?? 60,
      'is_active': true,
    };

    final response = await supabase
        .from('routes')
        .insert(routePayload)
        .select()
        .single();

    return response;
  }
}
