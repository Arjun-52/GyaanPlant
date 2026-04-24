import 'dart:convert';
import 'package:gyaanplant/models/HOD_models/hod_dashboard_model.dart';
import 'package:gyaanplant/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:gyaanplant/config/api_config.dart';

class HodDashboardService {
  // Using centralized ApiConfig for consistent base URL

  Future<HodDashboardModel> fetchDashboard(String token) async {
    print("🌍 BASE URL: ${ApiConfig.baseUrl}");
    print("🔐 TOKEN: $token");

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl("/api/v1/dashboard/hod")),
        headers: ApiConfig.buildAuthHeaders(token),
      );

      if (response.body.isEmpty) {
        throw Exception("Empty response from server");
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};

      if (response.statusCode != 200 || data["success"] != true) {
        final message =
            data["message"]?.toString() ?? "Failed to load dashboard";

        // Handle token expiry
        if (message.toLowerCase().contains("invalid token") ||
            message.toLowerCase().contains("unauthorized")) {
          await AuthService.clearToken();
          throw Exception("Session expired. Please login again.");
        }

        throw Exception(message);
      }

      final d = data["data"] as Map<String, dynamic>? ?? {};

      return HodDashboardModel.fromJson(d);
    } catch (e) {
      throw Exception("Failed to load dashboard: ${e.toString()}");
    }
  }
}
