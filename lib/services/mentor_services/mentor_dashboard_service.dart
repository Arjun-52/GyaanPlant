import 'dart:convert';
import 'package:gyaanplant/models/mentor_models/mentor_dashboard_model.dart';
import 'package:gyaanplant/config/api_config.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';
import 'package:http/http.dart' as http;

class MentorDashboardService {
  Future<MentorDashboardModel?> fetchDashboard() async {
    try {
      final token = await LocalStorageService.getToken();

      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl('/api/v1/dashboard/mentor')),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("🌐 RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MentorDashboardModel.fromJson(data);
      } else {
        print("❌ API ERROR: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ ERROR: $e");
      return null;
    }
  }
}
