import 'dart:convert';
import 'package:gyaanplant/models/HOD_models/department_model.dart';
import 'package:gyaanplant/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:gyaanplant/config/api_config.dart';

class DeptService {
  // Using centralized ApiConfig for consistent base URL

  Future<List<Department>> fetchDepts(String token) async {
    print("🌍 BASE URL: ${ApiConfig.baseUrl}");
    print("🔐 TOKEN: $token");

    final res = await http.get(
      Uri.parse(ApiConfig.buildUrl("/api/v1/departments")),
      headers: ApiConfig.buildAuthHeaders(token),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List? ?? [])
          .map((e) => Department.fromJson(e))
          .toList();
    } else {
      final message = data["message"] ?? "Failed to load departments";

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
