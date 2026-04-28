import 'dart:convert';
import 'package:gyaanplant/models/mentor_models/mentor_dashboard_model.dart';
import 'package:gyaanplant/services/student_services/base_api_service.dart';

class MentorDashboardService {
  Future<MentorDashboardModel?> fetchDashboard() async {
    try {
      final response = await BaseApiService.get('/api/v1/dashboard/mentor');

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
