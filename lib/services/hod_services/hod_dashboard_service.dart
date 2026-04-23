import 'dart:convert';
import 'package:gyaanplant/models/HOD_models/hod_dashboard_model.dart';
import 'package:http/http.dart' as http;

class HodDashboardService {
  final String baseUrl = "http://10.0.2.2:5000/api/v1/dashboard/hod";

  Future<HodDashboardModel> fetchDashboard(String token) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.body.isEmpty) {
        throw Exception("Empty response from server");
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};

      if (response.statusCode != 200 || data["success"] != true) {
        throw Exception(
          data["message"]?.toString() ?? "Failed to load dashboard",
        );
      }

      final d = data["data"] as Map<String, dynamic>? ?? {};

      return HodDashboardModel.fromJson(d);
    } catch (e) {
      throw Exception("Failed to load dashboard: ${e.toString()}");
    }
  }
}
