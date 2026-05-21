import '../core/utils/app_logger.dart';
import '../models/auth/college_dropdown_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class CollegeRepository {
  static const _tag = 'CollegeRepository';

  final NetworkAPIManager _api;
  CollegeRepository(this._api);

  /// Fetch college details by ID
  Future<ApiResponse<Map<String, dynamic>>> getCollegeById(String collegeId) {
    return _api.get<Map<String, dynamic>>(
      '${ApiEndpoints.college}/$collegeId',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Fetch all colleges (optional utility method)
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllColleges() {
    return _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.colleges,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      },
    );
  }

  /// Fetch colleges for the registration dropdown.
  ///
  /// Parses only [id], [name] and [city] — all other API fields are ignored.
  Future<ApiResponse<List<CollegeDropdownModel>>> getColleges() async {
    AppLogger.info(_tag, '🚀 FETCH COLLEGES — ${ApiEndpoints.colleges}');

    return _api.get<List<CollegeDropdownModel>>(
      ApiEndpoints.colleges,
      fromJson: (json) {
        // API may return a list directly or an object containing 'colleges' or 'data'
        List<dynamic> list;
        if (json is List) {
          list = json;
        } else if (json is Map<String, dynamic>) {
          list = (json['colleges'] ?? json['data'] ?? []) as List<dynamic>;
        } else {
          list = [];
        }
        AppLogger.info(_tag, 'Received ${list.length} colleges from API');
        return list
            .map((e) => CollegeDropdownModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}


