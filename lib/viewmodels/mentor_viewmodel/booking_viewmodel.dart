import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/booking_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class BookingViewModel extends ChangeNotifier {
  final _mentor = ApiService().mentor;

  List<Booking> bookings = [];
  bool isLoading = false;
  int selectedTab = 0;

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

  void changeTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  List<Booking> get pending =>
      bookings.where((b) => b.status == "pending").toList();

  List<Booking> get upcoming =>
      bookings.where((b) => b.status == "accepted").toList();

  List<Booking> get completed =>
      bookings.where((b) => b.status == "completed").toList();

  List<Booking> get currentBookings {
    switch (selectedTab) {
      case 0:
        return pending;
      case 1:
        return upcoming;
      case 2:
        return completed;
      default:
        return pending;
    }
  }

  Future<String?> updateBookingStatus(String id, String status) async {
    try {
      final result = await _mentor.updateBookingStatus(id, status);
      if (result.isSuccess) {
        // Update locally
        final index = bookings.indexWhere((b) => b.id == id);
        if (index != -1) {
          final b = bookings[index];
          bookings[index] = Booking(
            id: b.id,
            name: b.name,
            college: b.college,
            time: b.time,
            topic: b.topic,
            price: b.price,
            status: status,
          );
          notifyListeners();
        }
        return null;
      } else {
        return result.error?.message ?? "Failed to update booking status";
      }
    } catch (e) {
      return e.toString();
    }
  }
}
