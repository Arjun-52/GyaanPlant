import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/booking_model.dart';
import 'package:gyaanplant/services/mentor_services/booking_service.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingService _service = BookingService();

  List<Booking> bookings = [];
  bool isLoading = false;

  Future<void> loadBookings() async {
    isLoading = true;
    notifyListeners();

    bookings = await _service.fetchBookings();

    isLoading = false;
    notifyListeners();
  }

  List<Booking> get pending =>
      bookings.where((b) => b.status == "pending").toList();

  List<Booking> get upcoming =>
      bookings.where((b) => b.status == "accepted").toList();

  List<Booking> get completed =>
      bookings.where((b) => b.status == "completed").toList();
}
