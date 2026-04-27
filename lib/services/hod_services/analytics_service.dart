import 'dart:convert';
import 'package:gyaanplant/services/student_services/base_api_service.dart';

class AnalyticsService {
  // Using BaseApiService for consistent API calls

  Future<Map<String, dynamic>> fetchAnalytics(String token) async {
    print("🌍 ANALYTICS API CALL: /api/v1/dashboard/analytics");
    print("🔐 TOKEN: $token");

    try {
      final response = await BaseApiService.get('/api/v1/dashboard/analytics');

      print("📡 ANALYTICS RESPONSE STATUS: ${response.statusCode}");
      print("📄 ANALYTICS RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("🔍 ANALYTICS PARSED RESPONSE: $responseData");

        if (responseData['success'] == true) {
          final data = responseData['data'];
          print("📊 ANALYTICS DATA SECTION: $data");

          // Check for required fields
          print(
            "📊 DEPARTMENTS FIELD EXISTS: ${data.containsKey('departments')}",
          );
          print("📊 READINESS FIELD EXISTS: ${data.containsKey('readiness')}");
          print(
            "📊 PLACEMENT STATS FIELD EXISTS: ${data.containsKey('placementStats')}",
          );
          print(
            "📊 TOP PERFORMERS FIELD EXISTS: ${data.containsKey('topPerformers')}",
          );
          print(
            "📊 LOW PERFORMERS FIELD EXISTS: ${data.containsKey('lowPerformers')}",
          );

          return data;
        } else {
          throw Exception("API returned success: false");
        }
      } else {
        throw Exception("Failed to fetch analytics: ${response.statusCode}");
      }
    } catch (e) {
      print("ANALYTICS API ERROR: $e");
      rethrow;
    }
  }
}
