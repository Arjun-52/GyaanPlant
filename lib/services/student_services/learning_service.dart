import 'dart:convert';
import '../../core/utils/app_logger.dart';
import '../../models/student_role_models/course_model.dart';
import 'base_api_service.dart';

class LearningService {
  static const String _tag = 'LearningService';

  Future<List<CourseModel>> getCourses() async {
    AppLogger.info(_tag, 'Fetching courses');
    try {
      final response = await BaseApiService.get('/api/v1/learning');
      final responseData = jsonDecode(response.body);

      dynamic coursesData;
      if (responseData is Map<String, dynamic>) {
        coursesData = responseData.containsKey('data')
            ? responseData['data']
            : responseData;
      } else {
        coursesData = responseData;
      }

      List<CourseModel> courses;
      if (coursesData is List) {
        courses = coursesData
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (coursesData is Map<String, dynamic>) {
        courses = [CourseModel.fromJson(coursesData)];
      } else {
        courses = [];
      }

      AppLogger.info(_tag, 'Fetched ${courses.length} courses');
      return courses;
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to fetch courses', e, st);
      rethrow;
    }
  }
}
