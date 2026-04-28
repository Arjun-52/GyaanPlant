import '../models/tpo_role_models/drive_model.dart';
import '../models/tpo_role_models/student_model.dart';
import '../models/tpo_role_models/dashboard_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class TpoRepository {
  final NetworkAPIManager _api;
  TpoRepository(this._api);

  Future<ApiResponse<TpoDashboardModel>> getDashboard() {
    return _api.get<TpoDashboardModel>(
      ApiEndpoints.dashboardTpo,
      fromJson: (json) => TpoDashboardModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<Drive>>> getDrives() {
    return _api.get<List<Drive>>(
      ApiEndpoints.drives,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list.map((e) => Drive.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  Future<ApiResponse<List<Student>>> getStudents() {
    return _api.get<List<Student>>(
      ApiEndpoints.students,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list.map((e) => Student.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }
}
