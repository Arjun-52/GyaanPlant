import 'dart:convert';
import 'package:gyaanplant/models/mentor_models/mentor_dashboard_model.dart';
import 'package:gyaanplant/config/api_config.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';
import 'package:http/http.dart' as http;

class MentorDashboardService {
  Future<MentorDashboardModel?> fetchDashboard() async {
    try {
      // Get auth token from local storage
      final token = await LocalStorageService.getToken();
      print("🌍 BASE URL: ${ApiConfig.baseUrl}");
      print("🔐 TOKEN: $token");

      // TODO: Replace with actual API call when endpoint is ready
      // For now, return mock data for UI development
      print("🎨 USING MOCK DATA FOR UI DEVELOPMENT");

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Return mock data
      return MentorDashboardModel(
        name: "Dr. Arjun Kumar",
        role: "Alumni Mentor",
        sessionsDone: 24,
        earnings: 9600,
        rating: 4.8,
      );

      /* Uncomment when API is ready
      final response = await http
          .get(
            Uri.parse(ApiConfig.buildUrl('/api/v1/dashboard/mentor')),
            headers: token != null ? ApiConfig.buildAuthHeaders(token) : ApiConfig.headers,
          )
          .timeout(ApiConfig.timeout);
      
      print("🌐 MENTOR RAW RESPONSE:");
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MentorDashboardModel.fromJson(data);
      } else {
        return null;
      }
      */
    } catch (e) {
      print("❌ Error fetching mentor dashboard: $e");
      // Return mock data even on error for UI development
      return MentorDashboardModel(
        name: "Dr. Arjun Kumar",
        role: "Alumni Mentor",
        sessionsDone: 24,
        earnings: 9600,
        rating: 4.8,
      );
    }
  }
}
