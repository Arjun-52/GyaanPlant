import '../models/HOD_models/analytics_model.dart';
import '../models/HOD_models/department_model.dart';
import '../models/HOD_models/hod_dashboard_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class HodRepository {
  final NetworkAPIManager _api;
  HodRepository(this._api);

  Future<ApiResponse<HodDashboardModel>> getDashboard() {
    return _api.get<HodDashboardModel>(
      ApiEndpoints.dashboardHod,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return HodDashboardModel.fromJson(map['data'] as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResponse<AnalyticsModel>> getAnalytics() {
    return _api.get<AnalyticsModel>(
      ApiEndpoints.dashboardAnalytics,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return AnalyticsModel.fromJson(map['data'] as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResponse<List<Department>>> getDepartments() {
    print("🔍 HOD REPO: Fetching departments from ${ApiEndpoints.departments}");

    return _api.get<List<Department>>(
      ApiEndpoints.departments,
      fromJson: (json) {
        print("🔍 HOD REPO: Raw JSON response: $json");

        final map = json as Map<String, dynamic>;
        print("🔍 HOD REPO: Response keys: ${map.keys.toList()}");

        if (map.containsKey('data')) {
          final list = map['data'] as List<dynamic>? ?? [];
          print("🔍 HOD REPO: Data list length: ${list.length}");

          if (list.isNotEmpty) {
            print("🔍 HOD REPO: First raw department: ${list.first}");
          }

          final departments = list
              .map((e) => Department.fromJson(e as Map<String, dynamic>))
              .toList();
          print("🔍 HOD REPO: Parsed ${departments.length} departments");

          return departments;
        } else {
          print("❌ HOD REPO: No 'data' key found in response");
          return [];
        }
      },
    );
  }
}
