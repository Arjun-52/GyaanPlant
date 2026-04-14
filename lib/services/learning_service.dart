import 'dart:convert';
import 'package:gyaanplant/models/course_model.dart';
import 'base_api_service.dart';

class LearningService {
  Future<List<CourseModel>> getCourses() async {
    print('🚀 Learning API Call: /api/v1/learning');

    try {
      final response = await BaseApiService.get('/api/v1/learning');

      print('✅ Learning Response Status: ${response.statusCode}');
      print('📄 Learning Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('📊 Parsed Response Data: $responseData');

        // Handle different response structures
        dynamic coursesData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            coursesData = responseData['data'];
          } else {
            coursesData = responseData;
          }
        } else if (responseData is List) {
          coursesData = responseData;
        } else {
          coursesData = responseData;
        }

        print('🎯 Courses Data to Parse: $coursesData');

        List<CourseModel> courses = [];
        if (coursesData is List) {
          courses = coursesData
              .map((course) => CourseModel.fromJson(course))
              .toList();
        } else if (coursesData is Map<String, dynamic>) {
          // If it's a single course object
          courses.add(CourseModel.fromJson(coursesData));
        }

        return courses;
      } else {
        print('❌ Learning API Failed: ${response.statusCode}');
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Learning API Error: $e');
      rethrow;
    }
  }
}
