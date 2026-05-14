import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/booking_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class BookingViewModel extends ChangeNotifier {
  final _mentor = ApiService().mentor;

  List<Booking> bookings = [];
  bool isLoading = false;

  Future<void> loadBookings() async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _mentor.getBookings();
      if (result.isSuccess) bookings = result.data ?? [];
    } catch (e) {
      bookings = [];
    }

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
