import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class CollegeRepository {
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
}
