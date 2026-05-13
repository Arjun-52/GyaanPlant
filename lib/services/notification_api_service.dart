import 'dart:io';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../models/notification/notification_model.dart';
import '../network/api_manager.dart';
import '../network/api_endpoints.dart';

/// Service for handling notification API operations
class NotificationApiService {
  static const _tag = 'NotificationApiService';

  /// Fetch list of notifications from the backend.
  /// Returns an empty list on error so the UI can render its empty state.
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await NetworkAPIManager.instance.get(
        ApiEndpoints.notifications,
      );

      if (!response.success) {
        AppLogger.warning(
          _tag,
          'getNotifications failed: ${response.statusCode}',
        );
        throw Exception(
          'Failed to fetch notifications: ${response.statusCode}',
        );
      }

      final responseData = response.data;
      final List<dynamic> notificationsData =
          responseData is Map<String, dynamic>
              ? (responseData['data'] ?? responseData['notifications'] ?? [])
              : responseData is List
                  ? responseData
                  : [];

      final notifications = notificationsData
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      AppLogger.info(_tag, 'Fetched ${notifications.length} notifications');
      return notifications;
    } on SocketException catch (e, st) {
      AppLogger.error(_tag, 'Network error fetching notifications', e, st);
      throw Exception('Network error: Please check your internet connection');
    } catch (e, st) {
      AppLogger.error(_tag, 'Error fetching notifications', e, st);
      return [];
    }
  }

  /// Mark notification as read. Pass 'all' to mark every notification read.
  static Future<void> markAsRead(String id) async {
    try {
      final endpoint = id == 'all'
          ? '${ApiEndpoints.notifications}/read-all'
          : '${ApiEndpoints.notifications}/$id/read';

      final response = await NetworkAPIManager.instance.put(endpoint);

      if (response.success) {
        AppLogger.info(_tag, 'Marked notification as read: $id');
      } else {
        AppLogger.warning(
          _tag,
          'Mark-as-read failed ($id): ${response.statusCode}',
        );
        throw Exception(
          'Failed to mark notification as read: ${response.statusCode}',
        );
      }
    } on SocketException catch (e, st) {
      AppLogger.error(_tag, 'Network error marking as read', e, st);
      throw Exception('Network error: Please check your internet connection');
    } catch (e, st) {
      AppLogger.error(_tag, 'Error marking notification as read', e, st);
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read.
  static Future<void> markAllAsRead() => markAsRead('all');

  /// Get unread notifications count.
  static Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.read).length;
    } catch (e, st) {
      AppLogger.error(_tag, 'Error computing unread count', e, st);
      return 0;
    }
  }

  /// Delete a notification (if API supports it).
  static Future<void> deleteNotification(String id) async {
    try {
      final endpoint = '${ApiEndpoints.notifications}/$id';
      final response = await NetworkAPIManager.instance.delete(endpoint);

      if (response.success) {
        AppLogger.info(_tag, 'Deleted notification: $id');
      } else {
        AppLogger.warning(
          _tag,
          'Delete failed ($id): ${response.statusCode}',
        );
        throw Exception(
          'Failed to delete notification: ${response.statusCode}',
        );
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Error deleting notification', e, st);
      throw Exception('Failed to delete notification: $e');
    }
  }
}
