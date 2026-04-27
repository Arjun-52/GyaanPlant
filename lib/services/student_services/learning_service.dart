import 'dart:convert';
import 'package:gyaanplant/services/student_services/base_api_service.dart';

class LearningService {
  Future<List<dynamic>> getMyEnrollments(String token) async {
    print("TOKEN: $token");
    print("LEARNING API CALL: /api/v1/learning/my-courses");
    print("AUTH HEADER: Bearer $token");

    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final response = await BaseApiService.getWithHeaders(
        '/api/v1/learning/my-courses',
        headers,
      );

      print("LEARNING RESPONSE STATUS: ${response.statusCode}");
      print("LEARNING RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("LEARNING PARSED RESPONSE: $responseData");

        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception("API returned success: false");
        }
      } else {
        throw Exception("Failed to fetch enrollments: ${response.statusCode}");
      }
    } catch (e) {
      print("LEARNING API ERROR: $e");
      rethrow;
    }
  }
}
