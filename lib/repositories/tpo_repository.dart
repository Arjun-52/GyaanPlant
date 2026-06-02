import '../models/tpo_role_models/drive_model.dart';
import '../models/tpo_role_models/student_model.dart';

import '../network/api_endpoints.dart';
import '../core/utils/app_logger.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class TpoRepository {
  final NetworkAPIManager _api;
  TpoRepository(this._api);

  Future<ApiResponse<Map<String, dynamic>>> getDashboard() {
    return _api.get<Map<String, dynamic>>(
      ApiEndpoints.dashboardTpo,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Drive>>> getDrives() {
    return _api.get<List<Drive>>(
      ApiEndpoints.drives,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => Drive.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// POST /api/v1/drive — creates a new placement drive on the backend.
  Future<ApiResponse<Drive>> createDrive(Map<String, dynamic> payload) {
    AppLogger.info('TpoRepository', '🔀 TpoRepository.createDrive -> POST ${ApiEndpoints.drives}');
    AppLogger.debug('TpoRepository', '📨 Payload: $payload');
    return _api.post<Drive>(
      ApiEndpoints.drives,
      data: payload,
      fromJson: (json) {
        AppLogger.debug('TpoRepository', '📦 Raw createDrive response: $json');
        if (json is Map<String, dynamic>) {
          final data = json['data'];
          if (data is Map<String, dynamic>) {
            return Drive.fromJson(data);
          }
          return Drive.fromJson(json);
        }
        throw Exception('Unexpected createDrive response format');
      },
    );
  }


  Future<ApiResponse<List<Student>>> getStudents(String collegeId) {
    AppLogger.info('TpoRepository', '🌐 STUDENT API REQUEST:');
    AppLogger.debug('TpoRepository', 'URL: ${ApiEndpoints.students}');
    AppLogger.debug('TpoRepository', 'QUERY PARAMS: {college: $collegeId}');

    return _api.get<List<Student>>(
      ApiEndpoints.students,
      queryParameters: {'college': collegeId},
      fromJson: (json) {
        AppLogger.debug('TpoRepository', '📦 RAW RESPONSE: $json');
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        final students = list
            .map((e) => Student.fromJson(e as Map<String, dynamic>))
            .toList();
        AppLogger.info('TpoRepository', '📊 FILTERED STUDENTS COUNT: ${students.length}');
        return students;
      },
    );
  }

  Future<ApiResponse<Student>> onboardStudent({
    required String name,
    required String email,
    required String branch,
    required int year,
    required String rollNo,
    required double cgpa,
    required String careerPath,
    required String collegeId,
  }) {
    final payload = {
      'name': name,
      'email': email,
      'branch': branch,
      'year': year,
      'rollNo': rollNo,
      'rollNumber': rollNo,
      'cgpa': cgpa,
      'careerPath': careerPath,
      'college': collegeId,
    };

    AppLogger.info('TpoRepository', '🔀 TPO.onboardStudent -> POST ${ApiEndpoints.students}');
    AppLogger.debug('TpoRepository', '📨 Request payload: $payload');

    return _api.post<Student>(
      ApiEndpoints.students,
      data: payload,
      fromJson: (json) {
        AppLogger.debug('TpoRepository', '📦 Raw onboard response: $json');
        if (json is Map<String, dynamic>) {
          final data = json['data'];
          if (data is Map<String, dynamic>) {
            return Student.fromJson(data);
          }
          return Student.fromJson(json);
        }
        throw Exception('Invalid JSON response format for student onboarding');
      },
    );
  }
}
