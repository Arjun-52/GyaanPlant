import 'dart:convert';
import 'package:gyaanplant/models/HOD_models/analytics_model.dart';
import 'package:gyaanplant/services/auth_service.dart';
import 'package:http/http.dart' as http;

class AnalyticsService {
  final String baseUrl = "http://10.0.2.2:5000/api/v1/dashboard/analytics";

  Future<AnalyticsModel> fetchAnalytics(String token) async {
    print("TOKEN USED: $token");

    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return AnalyticsModel.fromJson(data["data"]);
    } else {
      final message = data["message"] ?? "Failed to load analytics";

      // Handle token expiry
      if (message.toString().toLowerCase().contains("invalid token") ||
          message.toString().toLowerCase().contains("unauthorized")) {
        await AuthService.clearToken();
        throw Exception("Session expired. Please login again.");
      }

      throw Exception(message);
    }
  }
}
