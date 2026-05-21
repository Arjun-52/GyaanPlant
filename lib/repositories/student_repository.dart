import '../models/student/student_dashboard_model.dart';
import '../models/student/student_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class StudentRepository {
  final NetworkAPIManager _api;

  StudentRepository(this._api);

  /// GET /api/v1/student — admin/hod/tpo role
  Future<ApiResponse<List<StudentModel>>> getAllStudents() {
    return _api.get<List<StudentModel>>(
      ApiEndpoints.students,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;
        return list
            .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// GET /api/v1/student/:id
  Future<ApiResponse<StudentModel>> getStudentById(String id) {
    return _api.get<StudentModel>(
      '${ApiEndpoints.students}/$id',
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return StudentModel.fromJson(map['data'] as Map<String, dynamic>);
      },
    );
  }

  /// GET /api/v1/student/me — student role only
  Future<ApiResponse<StudentModel>> getMyProfile() {
    return _api.get<StudentModel>(
      ApiEndpoints.studentMe,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return StudentModel.fromJson(map['data'] as Map<String, dynamic>);
      },
    );
  }

  /// GET /api/v1/dashboard/student — student role only
  Future<ApiResponse<StudentDashboard>> getDashboard() {
    print("📡 [StudentRepository.getDashboard] Starting API call...");
    return _api.get<StudentDashboard>(
      ApiEndpoints.dashboardStudent,
      fromJson: (json) {
        print("📡 [StudentRepository.getDashboard] Raw API response: $json");
        
        try {
          final map = json as Map<String, dynamic>;
          print("📡 [StudentRepository.getDashboard] Extracted map: $map");
          
          final dataField = map['data'];
          print("📡 [StudentRepository.getDashboard] Data field: $dataField, type: ${dataField.runtimeType}");
          
          if (dataField == null) {
            print("⚠️  [StudentRepository.getDashboard] Data field is null!");
            throw Exception('Dashboard data field is null');
          }
          
          final dashboardData = dataField as Map<String, dynamic>;
          print("📡 [StudentRepository.getDashboard] Calling StudentDashboard.fromJson with: $dashboardData");
          
          final result = StudentDashboard.fromJson(dashboardData);
          print("✅ [StudentRepository.getDashboard] Successfully parsed StudentDashboard");
          return result;
        } catch (e, st) {
          print("❌ [StudentRepository.getDashboard] Error during parsing: $e");
          print(st);
          rethrow;
        }
      },
    );
  }

  /// PUT /api/v1/student/:id — update student profile
  Future<ApiResponse<StudentModel>> updateStudent(
    String id,
    Map<String, dynamic> data,
  ) {
    return _api.put<StudentModel>(
      '${ApiEndpoints.students}/$id',
      data: data,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return StudentModel.fromJson(map['data'] as Map<String, dynamic>);
      },
    );
  }
}
