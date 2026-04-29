import '../models/learning/learning_model.dart';
import '../models/student_role_models/dashboard_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class LearningRepository {
  final NetworkAPIManager _api;

  LearningRepository(this._api);

  /// ✅ Get ALL Courses (matches Postman: /api/v1/learning)
  Future<ApiResponse<List<CourseModel>>> getCourses({
    int page = 1,
    int limit = 20,
  }) {
    return _api.get<List<CourseModel>>(
      ApiEndpoints.learning,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;

        return list
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Optional: Get single course
  Future<ApiResponse<CourseModel>> getCourseById(String id) {
    return _api.get<CourseModel>(
      '${ApiEndpoints.learning}/$id',
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return CourseModel.fromJson(map['data']);
      },
    );
  }

  /// ✅ Get ALL Assessments (matches Postman: /api/v1/learning/assessments)
  Future<ApiResponse<List<AssessmentModel>>> getAssessments({
    int page = 1,
    int limit = 20,
  }) {
    return _api.get<List<AssessmentModel>>(
      ApiEndpoints.assessments,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;

        return list
            .map((e) => AssessmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// ✅ Get My Enrollments (matches Postman: /api/v1/learning/my-courses)
  Future<ApiResponse<List<Enrollment>>> getMyEnrollments() {
    return _api.get<List<Enrollment>>(
      ApiEndpoints.myEnrollments,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;

        return list
            .map((e) => Enrollment.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
