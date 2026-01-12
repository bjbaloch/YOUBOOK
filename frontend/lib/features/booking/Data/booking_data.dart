import '../../../core/models/booking.dart';

class MyBookingData {
  bool isBusSelected;
  bool isPaidSelected;
  List<BookingModel> bookings;

  MyBookingData({
    this.isBusSelected = true,
    this.isPaidSelected = true,
    List<BookingModel>? bookings,
  }) : bookings = bookings ?? [];

  // Get filtered bookings based on current selection
  List<BookingModel> getFilteredBookings() {
    return bookings.where((booking) {
      final vehicleMatch = isBusSelected ? booking.isBus : booking.isVan;
      final statusMatch = isPaidSelected ? booking.isPaid : booking.isUnpaid;
      return vehicleMatch && statusMatch;
    }).toList();
  }

  // Add a new booking
  void addBooking(BookingModel booking) {
    bookings.add(booking);
  }

  // Remove a booking
  void removeBooking(String bookingId) {
    bookings.removeWhere((booking) => booking.id == bookingId);
  }

  // Update booking status
  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    final index = bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      bookings[index] = bookings[index].copyWith(status: newStatus);
    }
  }

  // Get booking by ID
  BookingModel? getBookingById(String bookingId) {
    return bookings.firstWhere((booking) => booking.id == bookingId);
  }
}
