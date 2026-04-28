import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gyaanplant/models/tpo_role_models/student_model.dart';
import 'package:gyaanplant/config/api_config.dart';

import '../../data/services/local_storage_service.dart';

/// Service class for handling student-related API calls
class StudentsService {
  // Using centralized ApiConfig for consistent base URL

  /// Debug helper to validate token
  static void _debugToken(String? token, String methodName) {
    print("=== TOKEN DEBUG ($methodName) ===");
    print("Token null: ${token == null ? 'YES' : 'NO'}");
    print("Token empty: ${token?.isEmpty == true ? 'YES' : 'NO'}");
    print("Token length: ${token?.length ?? 0}");

    if (token != null) {
      if (token.isEmpty) {
        print("ERROR: Token is empty string!");
      } else if (token.startsWith('Bearer')) {
        print("WARNING: Token already contains 'Bearer' prefix");
        print(
          "Token preview: ${token.length > 20 ? token.substring(0, 20) + '...' : token}",
        );
      } else {
        print(
          "Token preview: ${token.length > 20 ? token.substring(0, 20) + '...' : token}",
        );
      }

      // Check for common issues
      if (token.contains(' ')) {
        print("WARNING: Token contains spaces");
      }
      if (token.length < 10) {
        print("WARNING: Token seems too short");
      }
    } else {
      print("ERROR: Token is null - This will cause 401!");
    }
    print("===============================");
  }

  /// Test API endpoint accessibility
  static Future<void> testApiEndpoint() async {
    print("=== API ENDPOINT TEST ===");
    try {
      final token = await LocalStorageService.getToken();
      print("Testing endpoint: ${ApiConfig.buildUrl('/api/v1/student')}");
      print("With token: ${token != null ? 'YES' : 'NO'}");

      final response = await http
          .get(
            Uri.parse(ApiConfig.buildUrl("/api/v1/student")),
            headers: token != null
                ? ApiConfig.buildAuthHeaders(token)
                : ApiConfig.headers,
          )
          .timeout(const Duration(seconds: 10));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Try without token
      print("\n--- Testing WITHOUT token ---");
      final responseNoToken = await http
          .get(
            Uri.parse(ApiConfig.buildUrl("/api/v1/student")),
            headers: ApiConfig.headers,
          )
          .timeout(const Duration(seconds: 10));

      print("Response status (no token): ${responseNoToken.statusCode}");
      print("Response body (no token): ${responseNoToken.body}");
    } catch (e) {
      print("API endpoint test failed: $e");
    }
    print("========================");
  }

  /// Fetch all students from API
  /// GET /api/v1/students (or your actual endpoint)
  Future<List<Student>> fetchStudents() async {
    try {
      // Get authentication token
      final token = await LocalStorageService.getToken();

      // DEBUG: Token validation
      _debugToken(token, "fetchStudents");

      print("Fetching students from: ${ApiConfig.buildUrl('/api/v1/student')}");
      print(
        "Final Authorization header: ${token != null ? 'Bearer $token' : 'NO TOKEN'}",
      );

      final response = await http
          .get(
            Uri.parse(ApiConfig.buildUrl("/api/v1/student")),
            headers: token != null
                ? ApiConfig.buildAuthHeaders(token)
                : ApiConfig.headers,
          )
          .timeout(ApiConfig.timeout);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Check if response has success flag
        if (json['success'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          print("Parsed ${data.length} students");

          return data.map((e) => Student.fromJson(e)).toList();
        } else {
          throw Exception("API returned success: false");
        }
      }

      // Handle error responses
      String errorMessage = "Failed to load students";
      try {
        final errorJson = jsonDecode(response.body);
        errorMessage = errorJson['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = "HTTP ${response.statusCode}: ${response.body}";
      }

      throw Exception(errorMessage);
    } catch (e) {
      print("Error in fetchStudents: $e");
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Get student by ID (optional method for future use)
  Future<Student?> getStudentById(String id) async {
    try {
      final token = await LocalStorageService.getToken();

      // DEBUG: Token validation
      _debugToken(token, "getStudentById");

      final response = await http
          .get(
            Uri.parse(ApiConfig.buildUrl("/api/v1/student/$id")),
            headers: token != null
                ? ApiConfig.buildAuthHeaders(token)
                : ApiConfig.headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return Student.fromJson(json['data']);
        }
      }

      return null;
    } catch (e) {
      print("Error in getStudentById: $e");
      return null;
    }
  }
}
