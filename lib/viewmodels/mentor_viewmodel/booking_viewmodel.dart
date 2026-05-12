import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/mentor_models/booking_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class BookingViewModel extends ChangeNotifier {
  static const _tag = 'BookingViewModel';

  final _mentor = ApiService().mentor;

  List<Booking> bookings = [];
  bool isLoading = false;
  String? error;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> loadBookings() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _mentor.getBookings();
      if (result.isSuccess) {
        bookings = result.data ?? [];
        AppLogger.info(_tag, 'Loaded ${bookings.length} bookings');
      } else {
        bookings = [];
        error = result.error?.message ?? 'Failed to load bookings';
        AppLogger.error(_tag, error!);
      }
    } catch (e, st) {
      bookings = [];
      error = e.toString();
      AppLogger.error(_tag, 'Failed to load bookings', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  List<Booking> get pending => bookings.where((b) => b.status == 'pending').toList();
  List<Booking> get upcoming => bookings.where((b) => b.status == 'accepted').toList();
  List<Booking> get completed => bookings.where((b) => b.status == 'completed').toList();
}
