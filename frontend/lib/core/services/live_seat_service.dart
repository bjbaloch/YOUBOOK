import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SeatData {
  final String seatId;
  final String vehicleId;
  final int seatNumber;
  final String seatType; // 'male', 'female', 'general'
  final bool isAvailable;
  final bool isBooked;
  final String? bookedBy;
  final DateTime? bookedAt;
  final DateTime lastUpdated;

  const SeatData({
    required this.seatId,
    required this.vehicleId,
    required this.seatNumber,
    required this.seatType,
    required this.isAvailable,
    required this.isBooked,
    this.bookedBy,
    this.bookedAt,
    required this.lastUpdated,
  });

  factory SeatData.fromJson(Map<String, dynamic> json) {
    return SeatData(
      seatId: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      seatNumber: json['seat_number'] as int,
      seatType: json['seat_type'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      isBooked: json['is_booked'] as bool? ?? false,
      bookedBy: json['booked_by'] as String?,
      bookedAt: json['booked_at'] != null ? DateTime.parse(json['booked_at']) : null,
      lastUpdated: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': seatId,
      'vehicle_id': vehicleId,
      'seat_number': seatNumber,
      'seat_type': seatType,
      'is_available': isAvailable,
      'is_booked': isBooked,
      'booked_by': bookedBy,
      'booked_at': bookedAt?.toIso8601String(),
      'updated_at': lastUpdated.toIso8601String(),
    };
  }

  SeatData copyWith({
    String? seatId,
    String? vehicleId,
    int? seatNumber,
    String? seatType,
    bool? isAvailable,
    bool? isBooked,
    String? bookedBy,
    DateTime? bookedAt,
    DateTime? lastUpdated,
  }) {
    return SeatData(
      seatId: seatId ?? this.seatId,
      vehicleId: vehicleId ?? this.vehicleId,
      seatNumber: seatNumber ?? this.seatNumber,
      seatType: seatType ?? this.seatType,
      isAvailable: isAvailable ?? this.isAvailable,
      isBooked: isBooked ?? this.isBooked,
      bookedBy: bookedBy ?? this.bookedBy,
      bookedAt: bookedAt ?? this.bookedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class LiveSeatService {
  static final LiveSeatService _instance = LiveSeatService._internal();
  factory LiveSeatService() => _instance;
  LiveSeatService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, StreamController<List<SeatData>>> _vehicleSeatControllers = {};
  final Map<String, Timer> _updateTimers = {};

  // Watch seat availability for a vehicle
  Stream<List<SeatData>> watchSeats(String vehicleId) {
    if (!_vehicleSeatControllers.containsKey(vehicleId)) {
      _vehicleSeatControllers[vehicleId] = StreamController<List<SeatData>>.broadcast();
      _startSeatUpdates(vehicleId);
    }

    return _vehicleSeatControllers[vehicleId]!.stream;
  }

  // Start periodic seat updates
  void _startSeatUpdates(String vehicleId) {
    _updateTimers[vehicleId] = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchSeatUpdates(vehicleId),
    );

    // Initial fetch
    _fetchSeatUpdates(vehicleId);
  }

  // Fetch seat updates from database
  Future<void> _fetchSeatUpdates(String vehicleId) async {
    try {
      final response = await _supabase
        .from('seats')
        .select()
        .eq('vehicle_id', vehicleId)
        .order('seat_number');

      final seats = response.map((json) => SeatData.fromJson(json)).toList();
      _vehicleSeatControllers[vehicleId]?.add(seats);
    } catch (e) {
      debugPrint('Error fetching seat updates: $e');
    }
  }

  // Reserve seats temporarily (for booking process)
  Future<bool> reserveSeats({
    required String vehicleId,
    required List<int> seatNumbers,
    required String userId,
    Duration lockDuration = const Duration(minutes: 5),
  }) async {
    try {
      // Check if seats are available
      final availableSeats = await _getAvailableSeats(vehicleId, seatNumbers);
      if (availableSeats.length != seatNumbers.length) {
        return false; // Some seats not available
      }

      // Reserve seats
      final lockExpiry = DateTime.now().add(lockDuration);
      for (final seatNumber in seatNumbers) {
        await _supabase
          .from('seats')
          .update({
            'is_available': false,
            'booked_by': userId,
            'booked_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vehicle_id', vehicleId)
          .eq('seat_number', seatNumber);
      }

      // Trigger update
      _fetchSeatUpdates(vehicleId);

      // Auto-unlock after timeout
      Timer(lockDuration, () => _unlockSeats(vehicleId, seatNumbers));

      return true;
    } catch (e) {
      debugPrint('Error reserving seats: $e');
      return false;
    }
  }

  // Confirm seat booking
  Future<bool> confirmSeatBooking({
    required String vehicleId,
    required List<int> seatNumbers,
    required String userId,
    required String bookingId,
  }) async {
    try {
      for (final seatNumber in seatNumbers) {
        await _supabase
          .from('seats')
          .update({
            'is_booked': true,
            'booking_id': bookingId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vehicle_id', vehicleId)
          .eq('seat_number', seatNumber)
          .eq('booked_by', userId);
      }

      _fetchSeatUpdates(vehicleId);
      return true;
    } catch (e) {
      debugPrint('Error confirming seat booking: $e');
      return false;
    }
  }

  // Unlock seats (for timeout or cancellation)
  Future<void> _unlockSeats(String vehicleId, List<int> seatNumbers) async {
    try {
      for (final seatNumber in seatNumbers) {
        await _supabase
          .from('seats')
          .update({
            'is_available': true,
            'booked_by': null,
            'booked_at': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vehicle_id', vehicleId)
          .eq('seat_number', seatNumber);
      }

      _fetchSeatUpdates(vehicleId);
    } catch (e) {
      debugPrint('Error unlocking seats: $e');
    }
  }

  // Cancel seat reservation
  Future<void> cancelSeatReservation({
    required String vehicleId,
    required List<int> seatNumbers,
    required String userId,
  }) async {
    await _unlockSeats(vehicleId, seatNumbers);
  }

  // Get available seats for booking
  Future<List<int>> getAvailableSeats(String vehicleId) async {
    try {
      final response = await _supabase
        .from('seats')
        .select('seat_number')
        .eq('vehicle_id', vehicleId)
        .eq('is_available', true)
        .eq('is_booked', false);

      return response.map((seat) => seat['seat_number'] as int).toList();
    } catch (e) {
      debugPrint('Error getting available seats: $e');
      return [];
    }
  }

  // Get seat layout configuration
  Future<Map<String, dynamic>?> getSeatLayout(String vehicleId) async {
    try {
      final response = await _supabase
        .from('vehicles')
        .select('seat_layout, capacity')
        .eq('id', vehicleId)
        .single();

      return response;
    } catch (e) {
      debugPrint('Error getting seat layout: $e');
      return null;
    }
  }

  // Helper method to check seat availability
  Future<List<int>> _getAvailableSeats(String vehicleId, List<int> seatNumbers) async {
    final availableSeats = await getAvailableSeats(vehicleId);
    return seatNumbers.where((seat) => availableSeats.contains(seat)).toList();
  }

  // Stop watching seats
  void stopWatchingSeats(String vehicleId) {
    _updateTimers[vehicleId]?.cancel();
    _updateTimers.remove(vehicleId);
    _vehicleSeatControllers[vehicleId]?.close();
    _vehicleSeatControllers.remove(vehicleId);
  }

  // Cleanup
  void dispose() {
    for (final timer in _updateTimers.values) {
      timer.cancel();
    }
    _updateTimers.clear();

    for (final controller in _vehicleSeatControllers.values) {
      controller.close();
    }
    _vehicleSeatControllers.clear();
  }
}
