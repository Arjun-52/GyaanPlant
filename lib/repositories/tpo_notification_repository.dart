import '../models/tpo_role_models/tpo_notification_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class TpoNotificationRepository {
  final NetworkAPIManager _api;

  TpoNotificationRepository(this._api);

  /// Fetch notifications from backend using pagination
  Future<ApiResponse<TpoNotificationResponse>> getNotifications({
    required int page,
    required int limit,
  }) {
    return _api.get<TpoNotificationResponse>(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => TpoNotificationResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Mark a notification as read (supports individual ID or 'all' to mark all read)
  Future<ApiResponse<void>> markNotificationRead(String id) {
    return _api.put<void>(
      '${ApiEndpoints.notifications}/$id/read',
      fromJson: (_) {},
    );
  }

  /// Mark all notifications as read
  Future<ApiResponse<void>> markAllNotificationsRead() {
    return markNotificationRead('all');
  }
}
