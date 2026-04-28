import 'dart:convert';
import 'package:gyaanplant/services/student_services/base_api_service.dart';

class LearningService {
  Future<List<dynamic>> getMyEnrollments(String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await BaseApiService.getWithHeaders(
      '/api/v1/learning/my-courses',
      headers,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData['data'] as List<dynamic>;
      } else {
        throw Exception('API returned success: false');
      }
    } else {
      throw Exception('Failed to fetch enrollments: ${response.statusCode}');
    }
  }
}
