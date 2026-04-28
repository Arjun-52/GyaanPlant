import '../models/drive/drive_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class DriveRepository {
  final NetworkAPIManager _api;

  DriveRepository(this._api);

  Future<ApiResponse<DriveListResponse>> getDrives({
    int page = 1,
    int limit = 20,
  }) {
    return _api.get<DriveListResponse>(
      ApiEndpoints.drives,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;
        return DriveListResponse(
          drives: list
              .map((e) => DriveModel.fromJson(e as Map<String, dynamic>))
              .toList(),
          pagination: Pagination.fromJson(
            map['pagination'] as Map<String, dynamic>? ?? {},
          ),
        );
      },
    );
  }

  Future<ApiResponse<DriveModel>> getDriveById(String id) {
    return _api.get<DriveModel>(
      '${ApiEndpoints.drives}/$id',
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return DriveModel.fromJson(map['data'] as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResponse<List<DriveModel>>> getMyApplications() {
    return _api.get<List<DriveModel>>(
      ApiEndpoints.driveMyApplications,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;
        return list
            .map((e) => DriveModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<void>> applyToDrive(String driveId) {
    return _api.post<void>('${ApiEndpoints.drives}/$driveId/apply');
  }
}
