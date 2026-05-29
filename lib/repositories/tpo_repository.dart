import '../models/tpo_role_models/drive_model.dart';
import '../models/tpo_role_models/student_model.dart';

import '../network/api_endpoints.dart';
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
    print('🔀 TpoRepository.createDrive -> POST ${ApiEndpoints.drives}');
    print('📨 Payload: $payload');
    return _api.post<Drive>(
      ApiEndpoints.drives,
      data: payload,
      fromJson: (json) {
        print('📦 Raw createDrive response: $json');
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
    print("🌐 STUDENT API REQUEST:");
    print("URL: ${ApiEndpoints.students}");
    print("QUERY PARAMS: {college: $collegeId}");

    return _api.get<List<Student>>(
      ApiEndpoints.students,
      queryParameters: {'college': collegeId},
      fromJson: (json) {
        print("📦 RAW RESPONSE: $json");
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        final students = list
            .map((e) => Student.fromJson(e as Map<String, dynamic>))
            .toList();
        print("📊 FILTERED STUDENTS COUNT: ${students.length}");
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

    print('🔀 TPO.onboardStudent -> POST ${ApiEndpoints.students}');
    print('📨 Request payload: $payload');

    return _api.post<Student>(
      ApiEndpoints.students,
      data: payload,
      fromJson: (json) {
        print('📦 Raw onboard response: $json');
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
