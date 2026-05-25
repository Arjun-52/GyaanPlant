import '../models/learning/learning_model.dart';
import '../models/learning/detailed_course_model.dart';
import '../models/prep_pack_model.dart';
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

  /// Get Enrolled Courses (matches Postman: /api/v1/learning/my-courses)
  /// 🔥 GET ENROLLMENTS (CORRECT)
  Future<ApiResponse<List<Enrollment>>> getMyEnrollments() {
    return _api.get<List<Enrollment>>(
      ApiEndpoints.myEnrollments, // /learning/my-courses
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;

        return list
            .map((e) => Enrollment.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// ✅ Get single course by ID (matches Postman: /api/v1/learning/{id})
  Future<DetailedCourseModel> getCourseById(String id) async {
    final response = await _api.get<Map<String, dynamic>>(
      '${ApiEndpoints.learning}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    print("📦 COURSE DETAILS RESPONSE: ${response.data}");
    print("📦 COURSE TITLE: ${response.data?['data']?['title']}");

    return DetailedCourseModel.fromJson(response.data!['data']!);
  }

  /// Get Prep Packs (Test Packs)
  Future<ApiResponse<List<PrepPack>>> getPrepPacks() {
    return _api.get<List<PrepPack>>(
      ApiEndpoints.prepPacks,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;

        return list
            .map((e) => PrepPack.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Start Prep Pack Attempt
  Future<ApiResponse<Map<String, dynamic>>> startAttempt(String packId) {
    return _api.post<Map<String, dynamic>>(
      '${ApiEndpoints.startAttempt}/$packId/attempts/start',
      data: {},
    );
  }
}
