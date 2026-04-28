import '../models/learning/learning_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class LearningRepository {
  final NetworkAPIManager _api;

  LearningRepository(this._api);

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

  Future<ApiResponse<CourseModel>> getCourseById(String id) {
    return _api.get<CourseModel>(
      '${ApiEndpoints.learning}/$id',
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return CourseModel.fromJson(map['data'] as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResponse<List<AssessmentModel>>> getAssessments() {
    return _api.get<List<AssessmentModel>>(
      ApiEndpoints.assessments,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;
        return list
            .map((e) => AssessmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<List<dynamic>>> getMyEnrollments() {
    return _api.get<List<dynamic>>(
      ApiEndpoints.myEnrollments,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return map['data'] as List<dynamic>;
      },
    );
  }
}
