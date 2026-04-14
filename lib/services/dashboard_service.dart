import 'dart:convert';
import 'package:gyaanplant/models/dashboard_model.dart';
import 'base_api_service.dart';

class DashboardService {
  Future<DashboardModel> getDashboard() async {
    print('🚀 Dashboard API Call: /api/v1/dashboard/student');

    try {
      final response = await BaseApiService.get('/api/v1/dashboard/student');

      print('✅ Dashboard Response Status: ${response.statusCode}');
      print('📄 Dashboard Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('📊 Parsed Response Data: $responseData');

        // Handle different response structures
        dynamic dashboardData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            dashboardData = responseData['data'];
          } else {
            dashboardData = responseData;
          }
        } else {
          dashboardData = responseData;
        }

        print('🎯 Dashboard Data to Parse: $dashboardData');
        return DashboardModel.fromJson(dashboardData);
      } else {
        print('❌ Dashboard API Failed: ${response.statusCode}');
        throw Exception('Failed to load dashboard: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Dashboard API Error: $e');
      rethrow;
    }
  }
}
