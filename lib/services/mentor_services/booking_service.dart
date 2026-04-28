import 'dart:convert';
import 'package:gyaanplant/models/mentor_models/booking_model.dart';
import 'package:gyaanplant/services/student_services/base_api_service.dart';

class BookingService {
  Future<List<Booking>> fetchBookings() async {
    try {
      final response = await BaseApiService.get('/api/v1/session/my');

      print("📦 BOOKINGS: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] ?? [];

        return list.map<Booking>((e) => Booking.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print("❌ ERROR fetching bookings: $e");
      return [];
    }
  }
}
