import 'dart:convert';
import 'package:gyaanplant/models/HOD_models/department_model.dart';
import 'package:gyaanplant/services/auth_service.dart';
import 'package:gyaanplant/services/student_services/base_api_service.dart';
import 'package:gyaanplant/config/api_config.dart';

class DeptService {
  // Using centralized ApiConfig for consistent base URL

  Future<List<Department>> fetchDepts(String token) async {
    print("🌍 BASE URL: ${ApiConfig.baseUrl}");
    print("🔐 TOKEN: $token");

    print("🌐 API CALL: GET /api/v1/departments");

    final res = await BaseApiService.getWithHeaders(
      "/api/v1/departments",
      ApiConfig.buildAuthHeaders(token),
    );

    print("📡 DEPARTMENTS RESPONSE STATUS: ${res.statusCode}");
    print("📄 DEPARTMENTS RESPONSE BODY: ${res.body}");

    final data = jsonDecode(res.body);
    print("🔍 PARSED RESPONSE: $data");

    if (res.statusCode == 200 && data["success"] == true) {
      final dataList = data["data"] as List? ?? [];
      print("📊 DATA ARRAY TYPE: ${dataList.runtimeType}");
      print("📊 DATA ARRAY LENGTH: ${dataList.length}");

      if (dataList.isNotEmpty) {
        print("📊 FIRST DEPT ITEM: ${dataList[0]}");
        if (dataList.length > 1) {
          print("📊 SECOND DEPT ITEM: ${dataList[1]}");
        }
      }

      final departments = dataList.map((e) => Department.fromJson(e)).toList();

      print("🏢 PARSED DEPARTMENTS COUNT: ${departments.length}");
      for (int i = 0; i < departments.length; i++) {
        print(
          "🏢 DEPT $i: ${departments[i].name} (${departments[i].students} students)",
        );
      }

      return departments;
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
