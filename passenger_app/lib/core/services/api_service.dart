import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

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

  // Public method for passengers to get service details for seat selection
  Future<Map<String, dynamic>> getPublicServiceDetails(String serviceId) async {
    final response = await supabase
        .from('services')
        .select('''
          id, name, seat_layout, is_seat_layout_configured, capacity,
          from_location, to_location, route_name, base_price, features
        ''')
        .eq('id', serviceId)
        .eq('is_active', true)
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

      // Validate and normalize service type
      final rawType = serviceData['type']?.toString().toLowerCase();
      final serviceType = (rawType == 'van')
          ? 'van'
          : 'bus'; // Default to 'bus' if invalid

      final servicePayload = {
        'name': vehicleName, // vanName/busName
        'description':
            'Transport service from ${serviceData['from']} to ${serviceData['to']}',
        'type': serviceType, // Always 'bus' or 'van'
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
      // Fixed: Use direct joins instead of nested joins to avoid PostgREST relationship issues
      final response = await supabase
          .from('schedules')
          .select('*, services(*), vehicles(*), drivers(*, profiles(*))')
          .eq('services.manager_id', user.id)
          .order('departure_time', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback: Get schedules with simpler relationships
      final response = await supabase
          .from('schedules')
          .select('*, vehicles(*, services(*))')
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
          'TempPass${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}!';

      // Create a temporary Supabase client with service role key for admin operations
      final adminSupabase = SupabaseClient(
        SupabaseConfig.url,
        SupabaseConfig.serviceRoleKey,
      );

      // Call RPC function with admin privileges to create driver account with auth user
      final rpcResponse = await adminSupabase.rpc(
        'create_driver_user',
        params: {
          'p_email': driverData['email'],
          'p_password': tempPassword,
          'p_name': driverData['name'],
          'p_manager_id': user.id,
        },
      );

      if (rpcResponse == null || rpcResponse.isEmpty) {
        throw Exception(
          'Failed to create driver account - RPC returned no response',
        );
      }

      final responseData = rpcResponse[0];
      final authUserId = responseData['auth_user_id'];
      final driverId = responseData['driver_id'];

      if (authUserId == null || driverId == null) {
        throw Exception('RPC function did not return required IDs');
      }

      // Return the driver data with temporary password
      return {
        'id': driverId,
        'auth_user_id': authUserId,
        'email': driverData['email'],
        'name': driverData['name'],
        'phone': driverData['phone'],
        'license_number': driverData['license_number'],
        'current_status': 'Idle',
        'temp_password': tempPassword,
        'message': responseData['message'] ?? 'Driver created successfully',
      };
    } catch (e) {
      // Provide more specific error messages
      if (e.toString().contains('foreign key constraint')) {
        throw Exception(
          'Failed to create driver: The authentication user was not created properly. Please check the RPC function configuration.',
        );
      } else if (e.toString().contains('duplicate key')) {
        throw Exception(
          'A driver with this email or license number already exists.',
        );
      } else if (e.toString().contains('permission denied')) {
        throw Exception(
          'Permission denied: Unable to create driver account. Please check service role permissions.',
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateDriver(
    String driverId,
    Map<String, dynamic> driverData,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final updateData = {
        'name': driverData['name'],
        'email': driverData['email'],
        'phone': driverData['phone'],
        'license_number': driverData['license_number'],
        'current_status': driverData['current_status'] ?? 'Idle',
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('drivers')
          .update(updateData)
          .eq('id', driverId)
          .eq('company_id', user.id) // Ensure user owns the driver
          .select()
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDriver(String driverId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await supabase
          .from('drivers')
          .delete()
          .eq('id', driverId)
          .eq('company_id', user.id); // Ensure user owns the driver
    } catch (e) {
      rethrow;
    }
  }

  // Manager vehicles endpoints - now returns services for track vehicles screen
  Future<List<Map<String, dynamic>>> getManagerVehicles() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Return services instead of vehicles for track vehicles screen
      // This allows managers to see their added services
      final response = await supabase
          .from('services')
          .select('*')
          .eq('manager_id', user.id)
          .eq('is_active', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error loading services for vehicles screen: $e');
      return [];
    }
  }

  // Get vehicles for a specific service (shows all vehicles including inactive/maintenance)
  Future<List<Map<String, dynamic>>> getServiceVehicles(
    String serviceId,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('vehicles')
        .select('*')
        .eq('service_id', serviceId)
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

      // Get service capacity to ensure consistency
      final serviceResponse = await supabase
          .from('services')
          .select('capacity')
          .eq('id', serviceId)
          .eq('manager_id', user.id)
          .single();

      final serviceCapacity = serviceResponse['capacity'] ?? 50;

      final vehicleNumber =
          vehicleData['busNumber'] ??
          vehicleData['vanNumber'] ??
          'DEFAULT-${DateTime.now().millisecondsSinceEpoch}';

      final vehiclePayload = {
        'service_id': serviceId, // Associate with service for RLS policy
        'manager_id': user.id, // Required for RLS policy compliance
        'registration_number': vehicleNumber,
        'vehicle_number': vehicleNumber,
        'type': vehicleData['type'] ?? 'bus',
        'make':
            vehicleData['busName'] ??
            vehicleData['vanName'] ??
            'Default Vehicle',
        'model':
            vehicleData['busName'] ??
            vehicleData['vanName'] ??
            'Default Vehicle',
        'capacity': serviceCapacity, // Use service capacity for consistency
        'year': DateTime.now().year,
        'status': 'active',
        'fuel_type': 'diesel',
        'is_active': true,
        'seat_layout':
            vehicleData['seatLayoutData'] ??
            {'totalSeats': serviceCapacity, 'configured': true},
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

  Future<Map<String, dynamic>> updateVehicle(
    String vehicleId,
    Map<String, dynamic> vehicleData,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Only include fields that are provided and not null
      final vehiclePayload = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add provided fields, filtering out null values
      vehicleData.forEach((key, value) {
        if (value != null) {
          vehiclePayload[key] = value;
        }
      });

      final response = await supabase
          .from('vehicles')
          .update(vehiclePayload)
          .eq('id', vehicleId)
          .select('*, services(*)')
          .single();

      // Check ownership after update
      if (response['services']?['manager_id'] != user.id) {
        throw Exception('You do not have permission to update this vehicle');
      }

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
        .select('*, schedules(*, vehicles(*, services(*)))')
        .eq('passenger_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getPassengerWallet() async {
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
      // If wallet doesn't exist (0 rows), create one using RPC function
      if (e.toString().contains('PGRST116') ||
          e.toString().contains('0 rows')) {
        // Use process_wallet_transaction RPC to create wallet (bypasses RLS)
        final rpcResult = await supabase.rpc(
          'process_wallet_transaction',
          params: {
            'p_user_id': user.id,
            'p_amount': 0.0,
            'p_type': 'credit',
            'p_description': 'Wallet initialization',
          },
        );

        if (rpcResult != null && rpcResult is List && rpcResult.isNotEmpty) {
          final result = rpcResult[0] as Map<String, dynamic>;
          if (result['success'] == true) {
            // Now get the created wallet
            final walletResponse = await supabase
                .from('wallets')
                .select('*')
                .eq('user_id', user.id)
                .single();

            return walletResponse;
          }
        }

        throw Exception('Failed to create wallet');
      }
      // Re-throw other errors
      rethrow;
    }
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

  // Get available locations from scheduled routes
  Future<List<String>> getAvailableLocations({String? serviceType}) async {
    try {
      var query = supabase
          .from('schedules')
          .select('origin, destination')
          .eq('status', 'scheduled')
          .gt('available_seats', 0);

      // Note: serviceType filtering would require joining with services table
      // For now, return all locations from active schedules

      final response = await query;

      final locations = <String>{}; // Use Set to avoid duplicates

      for (final schedule in response) {
        final origin = schedule['origin'];
        final destination = schedule['destination'];

        if (origin != null && origin.isNotEmpty) {
          locations.add(origin);
        }
        if (destination != null && destination.isNotEmpty) {
          locations.add(destination);
        }
      }

      return locations.toList()..sort();
    } catch (e) {
      log('Error fetching available locations: $e');
      return [];
    }
  }

  // Create service-level booking (for services without schedules)
  Future<Map<String, dynamic>?> createServiceBooking({
    required String serviceId,
    required List<String> selectedSeatNumbers,
    required double totalPrice,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // First, deduct from wallet
      final walletDeduction = await addMoneyToWallet(
        -totalPrice,
        description: 'Service booking payment',
      );

      if (!walletDeduction) {
        throw Exception('Failed to deduct payment from wallet');
      }

      // Create booking record for the service (without schedule)
      final now = DateTime.now();
      final bookingData = {
        'passenger_id': user.id,
        'service_id': serviceId, // Reference service instead of schedule
        'booking_date': now
            .toIso8601String(), // Proper timestamp for booking_date
        'travel_date': now.toIso8601String().split(
          'T',
        )[0], // Date part for travel_date
        'total_price': totalPrice,
        'status': 'confirmed', // Service bookings are confirmed immediately
        'booking_type': 'service', // Distinguish from schedule bookings
        'selected_seats': selectedSeatNumbers, // Store selected seats as JSON
        'is_paid': true, // Service bookings are paid immediately
        'payment_method': 'wallet',
      };

      final bookingResponse = await supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      final bookingId = bookingResponse['id'];

      // Create booking seats (though we don't have a schedule, we still track seat reservations)
      // For now, we'll create minimal seat records - these can be updated when a schedule is assigned
      final seatData = selectedSeatNumbers
          .map(
            (seatNumber) => {
              'booking_id': bookingId,
              'seat_number': seatNumber, // Store seat number as string
              'status': 'reserved', // Mark as reserved for the service
            },
          )
          .toList();

      if (seatData.isNotEmpty) {
        await supabase.from('booking_seats').insert(seatData);
      }

      return bookingResponse;
    } catch (e) {
      // If booking creation fails, we should refund the wallet
      try {
        await addMoneyToWallet(
          totalPrice,
          description: 'Refund for failed booking',
        );
      } catch (refundError) {
        log('Failed to refund wallet after booking failure: $refundError');
      }
      rethrow;
    }
  }

  // Get available services with enhanced filtering
  Future<List<Map<String, dynamic>>> getAvailableServices({
    String? fromLocation,
    String? toLocation,
    String? serviceType,
  }) async {
    try {
      // Get ALL active services first
      var query = supabase
          .from('services')
          .select('''
            *,
            vehicles(
              id,
              status,
              is_active,
              seat_layout
            )
          ''')
          .eq('status', 'active') // Only active services
          .eq('is_active', true); // Only active services

      // Filter by locations if specified
      if (fromLocation != null) {
        query = query.ilike('from_location', '%$fromLocation%');
      }
      if (toLocation != null) {
        query = query.ilike('to_location', '%$toLocation%');
      }

      final response = await query;
      var services = List<Map<String, dynamic>>.from(response);

      // Filter by service type using both explicit type and capacity-based logic
      if (serviceType != null) {
        services = services.where((service) {
          final explicitType = service['type'] as String?;
          final capacity = service['capacity'] as int? ?? 50;

          // Use explicit type if available, otherwise use capacity-based logic
          if (explicitType == serviceType) {
            return true;
          }

          // Fallback to capacity-based logic for services without explicit type
          if (serviceType == 'van') {
            return capacity <= 15; // Vans have 15 or fewer seats
          } else if (serviceType == 'bus') {
            return capacity > 15; // Buses have more than 15 seats
          }

          return false;
        }).toList();
      }

      return services;
    } catch (e) {
      log('Error fetching available services: $e');
      return [];
    }
  }

  // Get available schedules for a specific service
  Future<List<Map<String, dynamic>>> getSchedulesForService(
    String serviceId, {
    DateTime? travelDate,
  }) async {
    try {
      var query = supabase
          .from('schedules')
          .select('''
            *,
            vehicles(*),
            drivers!fk_schedules_assigned_driver_id(name)
          ''')
          .eq('service_id', serviceId)
          .eq('status', 'scheduled') // Only active schedules
          .gt(
            'departure_time',
            DateTime.now().toIso8601String(),
          ); // Only future trips

      // Filter by travel date if specified
      if (travelDate != null) {
        final dateStr = travelDate.toIso8601String().split('T')[0];
        query = query.eq('travel_date', dateStr);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error fetching schedules for service: $e');
      return [];
    }
  }

  // Get available schedules with enhanced filtering
  Future<List<Map<String, dynamic>>> getAvailableSchedules({
    String? fromLocation,
    String? toLocation,
    DateTime? travelDate,
    String? serviceType,
  }) async {
    try {
      // Definitive fix: Start from vehicles table to guarantee proper service type filtering
      // This ensures buses screen shows only buses, vans screen shows only vans
      var query = supabase
          .from('vehicles')
          .select('''
            *,
            services(name, features, type, manager_id),
            schedules!inner(
              *,
              drivers!fk_schedules_assigned_driver_id(name)
            )
          ''')
          .eq(
            'services.type',
            serviceType ?? 'bus',
          ) // Direct filtering on services.type
          .eq('schedules.status', 'scheduled') // Only active schedules
          .gt(
            'schedules.departure_time',
            DateTime.now().toIso8601String(),
          ); // Only future trips

      // Filter by locations if specified (basic origin/destination matching)
      if (fromLocation != null) {
        query = query.ilike('schedules.origin', '%$fromLocation%');
      }
      if (toLocation != null) {
        query = query.ilike('schedules.destination', '%$toLocation%');
      }

      // Filter by travel date if specified
      if (travelDate != null) {
        final dateStr = travelDate.toIso8601String().split('T')[0];
        query = query.eq('schedules.travel_date', dateStr);
      }

      final response = await query;

      // Transform the response to match expected schedule format
      // Handle case where schedules is a List due to inner join
      final transformedResponse = response.map((item) {
        final schedules = item['schedules'] as List<dynamic>;
        final schedule = schedules.isNotEmpty
            ? schedules[0] as Map<String, dynamic>
            : <String, dynamic>{};
        final vehicle = Map<String, dynamic>.from(item)..remove('schedules');
        final service =
            item['services'] as Map<String, dynamic>? ?? <String, dynamic>{};

        return {...schedule, 'vehicles': vehicle, 'services': service};
      }).toList();

      return transformedResponse;
    } catch (e) {
      log('Error fetching available schedules: $e');
      return [];
    }
  }

  // Get wallet balance
  Future<double> getWalletBalance() async {
    final wallet = await getPassengerWallet();
    return (wallet['balance'] as num?)?.toDouble() ?? 0.0;
  }

  // Add money to wallet using RPC function (bypasses RLS)
  Future<bool> addMoneyToWallet(double amount, {String? description}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Use process_wallet_transaction RPC to add money (bypasses RLS)
      final rpcResult = await supabase.rpc(
        'process_wallet_transaction',
        params: {
          'p_user_id': user.id,
          'p_amount': amount,
          'p_type': 'credit',
          'p_description': description ?? 'Wallet top-up',
        },
      );

      if (rpcResult != null && rpcResult is List && rpcResult.isNotEmpty) {
        final result = rpcResult[0] as Map<String, dynamic>;
        return result['success'] == true;
      }

      return false;
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
      // Use the total_seats provided in scheduleData (comes from service capacity)
      final totalSeats = scheduleData['total_seats'] ?? 50;

      final schedulePayload = {
        'service_id': scheduleData['service_id'],
        'vehicle_id': scheduleData['vehicle_id'] ?? null,
        'origin': scheduleData['origin'], // Direct origin location
        'destination':
            scheduleData['destination'], // Direct destination location
        'assigned_driver_id': scheduleData['driver_id'] ?? null,
        'departure_time': scheduleData['departure_time'],
        'arrival_time': scheduleData['arrival_time'],
        'travel_date': scheduleData['travel_date'],
        'base_fare': scheduleData['base_fare'] ?? 0.0, // Price per seat
        'total_seats':
            totalSeats, // Use service capacity provided in scheduleData
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
        'vehicle_id': scheduleData['vehicle_id'] ?? null,
        'origin': scheduleData['origin'],
        'destination': scheduleData['destination'],
        'assigned_driver_id': scheduleData['driver_id'] ?? null,
        'departure_time': scheduleData['departure_time'],
        'arrival_time': scheduleData['arrival_time'],
        'travel_date': scheduleData['travel_date'],
        'base_fare': scheduleData['base_fare'],
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
      // First check ownership through vehicle->service relationship
      final schedule = await supabase
          .from('schedules')
          .select('*, vehicles(*, services(*))')
          .eq('id', scheduleId)
          .single();

      if (schedule['vehicles']?['services']?['manager_id'] != user.id) {
        throw Exception('You do not have permission to delete this schedule');
      }

      await supabase.from('schedules').delete().eq('id', scheduleId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getScheduleById(String scheduleId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('schedules')
        .select('*, vehicles(*), services(*), profiles(*)')
        .eq('id', scheduleId)
        .eq('services.manager_id', user.id) // Ensure user owns the service
        .single();

    return response;
  }

  // Get route locations from routes table (shows manager-added routes)
  Future<Map<String, List<String>>> getRouteLocationsByType({
    String? serviceType,
  }) async {
    try {
      var query = supabase
          .from('routes')
          .select('start_location, end_location, service_type')
          .eq('is_active', true);

      if (serviceType != null) {
        query = query.eq('service_type', serviceType);
      }

      final response = await query;

      final origins = <String>{}; // Use Set to avoid duplicates
      final destinations = <String>{}; // Use Set to avoid duplicates

      for (final route in response) {
        final startLocation = route['start_location'] as Map<String, dynamic>?;
        final endLocation = route['end_location'] as Map<String, dynamic>?;

        // Extract city from start_location (origins)
        final startCity = startLocation?['city'] ?? startLocation?['address'];
        if (startCity != null && startCity.isNotEmpty) {
          origins.add(startCity);
        }

        // Extract city from end_location (destinations)
        final endCity = endLocation?['city'] ?? endLocation?['address'];
        if (endCity != null && endCity.isNotEmpty) {
          destinations.add(endCity);
        }
      }

      return {
        'origins': origins.toList()..sort(),
        'destinations': destinations.toList()..sort(),
      };
    } catch (e) {
      log('Error fetching route locations: $e');
      return {'origins': [], 'destinations': []};
    }
  }

  // Routes operations
  Future<List<Map<String, dynamic>>> getRoutes({String? serviceType}) async {
    var query = supabase.from('routes').select('*').eq('is_active', true);

    if (serviceType != null) {
      query = query.eq('service_type', serviceType);
    }

    final response = await query.order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createRoute(
    Map<String, dynamic> routeData,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final routePayload = {
      'name': routeData['name'],
      'service_type': routeData['service_type'] ?? 'bus',
      'service_id': routeData['service_id'], // Link route to specific service
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
