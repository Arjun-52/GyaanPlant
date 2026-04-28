import 'dart:convert';
import 'package:gyaanplant/models/mentor_models/booking_model.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../data/services/local_storage_service.dart';

class BookingService {
  Future<List<Booking>> fetchBookings() async {
    final token = await LocalStorageService.getToken();

    final response = await http.get(
      Uri.parse(ApiConfig.buildUrl('/api/v1/session/my')),
      headers: {"Authorization": "Bearer $token"},
    );

    print("📦 BOOKINGS: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] ?? [];

      return list.map<Booking>((e) => Booking.fromJson(e)).toList();
    }

    return [];
  }
}
