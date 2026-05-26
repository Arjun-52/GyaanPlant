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
    print("🔥 HOD REPO: GETTING DASHBOARD FROM ${ApiEndpoints.dashboardHod}");

    return _api.get<HodDashboardModel>(
      ApiEndpoints.dashboardHod,
      fromJson: (json) {
        print("🔥 HOD REPO: RAW JSON RESPONSE: $json");

        final map = json as Map<String, dynamic>;
        print("🔥 HOD REPO: RESPONSE KEYS: ${map.keys.toList()}");

        if (map.containsKey('data')) {
          final data = map['data'];
          print("🔥 HOD REPO: DATA SECTION: $data");
          print("🔥 HOD REPO: DATA TYPE: ${data.runtimeType}");

          if (data is Map<String, dynamic>) {
            print("🔥 HOD REPO: DATA KEYS: ${data.keys.toList()}");

            // Check for departmentStats specifically
            if (data.containsKey('departmentStats')) {
              final deptStats = data['departmentStats'];
              print("🔥 HOD REPO: DEPARTMENT STATS: $deptStats");
              print(
                "🔥 HOD REPO: DEPARTMENT STATS TYPE: ${deptStats.runtimeType}",
              );

              if (deptStats is List) {
                print(
                  "🔥 HOD REPO: DEPARTMENT STATS LENGTH: ${deptStats.length}",
                );
                if (deptStats.isNotEmpty) {
                  print("🔥 HOD REPO: FIRST DEPARTMENT: ${deptStats.first}");
                }
              }
            } else {
              print("❌ HOD REPO: NO 'departmentStats' KEY FOUND IN DATA");
            }

            // Check for overview
            if (data.containsKey('overview')) {
              print("🔥 HOD REPO: OVERVIEW: ${data['overview']}");
            } else {
              print("❌ HOD REPO: NO 'overview' KEY FOUND IN DATA");
            }

            return HodDashboardModel.fromJson(data);
          } else {
            print("❌ HOD REPO: DATA IS NOT A MAP - TYPE: ${data.runtimeType}");
            throw Exception(
              "Invalid data format: expected Map<String, dynamic>",
            );
          }
        } else {
          print("❌ HOD REPO: NO 'data' KEY FOUND IN RESPONSE");
          throw Exception("No data key found in response");
        }
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
        }
        return [];
      },
    );
  }
  // Fetch details for a single department by ID
  Future<ApiResponse<Department>> getDepartmentDetails(String departmentId) {
    final endpoint = "${ApiEndpoints.departments}/$departmentId";
    print("🔍 HOD REPO: Fetching department details from $endpoint");
    return _api.get<Department>(
      endpoint,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'] as Map<String, dynamic>? ?? {};
        return Department.fromJson(data);
      },
    );
  }

}
