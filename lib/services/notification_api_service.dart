import 'dart:io';
import '../models/notification/notification_model.dart';
import '../network/api_manager.dart';
import '../network/api_endpoints.dart';

/// Service for handling notification API operations
class NotificationApiService {
  /// Fetch list of notifications from the backend
  /// Returns empty list if no notifications or error occurs
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      print("🔔 Fetching notifications from API...");

      final response = await NetworkAPIManager.instance.get(
        ApiEndpoints.notifications,
      );

      print("📦 API Response: ${response.statusCode}");

      if (response.success) {
        final responseData = response.data;

        // Handle both nested and direct response structures
        final List<dynamic> notificationsData =
            responseData is Map<String, dynamic>
            ? responseData['data'] ?? responseData['notifications'] ?? []
            : responseData is List
            ? responseData
            : [];

        print("📋 Found ${notificationsData.length} notifications");

        final notifications = notificationsData
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        print("✅ Successfully parsed ${notifications.length} notifications");
        return notifications;
      } else {
        print("❌ API Error: ${response.statusCode} - ${response.message}");
        throw Exception(
          'Failed to fetch notifications: ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      print("❌ Network Error: $e");
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      print("❌ Error fetching notifications: $e");
      return []; // Return empty list on error to prevent UI crashes
    }
  }

  /// Mark notification as read
  /// Use 'all' as id to mark all notifications as read
  static Future<void> markAsRead(String id) async {
    try {
      print("🔔 Marking notification as read: $id");

      final endpoint = id == 'all'
          ? '${ApiEndpoints.notifications}/read-all'
          : '${ApiEndpoints.notifications}/$id/read';

      final response = await NetworkAPIManager.instance.put(endpoint);

      print("📦 Mark as read response: ${response.statusCode}");

      if (response.success) {
        print("✅ Successfully marked notification as read: $id");
      } else {
        print(
          "❌ API Error marking as read: ${response.statusCode} - ${response.message}",
        );
        throw Exception(
          'Failed to mark notification as read: ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      print("❌ Network Error marking as read: $e");
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      print("❌ Error marking notification as read: $e");
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead() async {
    await markAsRead('all');
  }

  /// Get unread notifications count
  static Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      final unreadCount = notifications.where((n) => !n.read).length;
      print("📊 Unread notifications count: $unreadCount");
      return unreadCount;
    } catch (e) {
      print("❌ Error getting unread count: $e");
      return 0;
    }
  }

  /// Delete a notification (if API supports it)
  static Future<void> deleteNotification(String id) async {
    try {
      print("🗑️ Deleting notification: $id");

      final endpoint = '${ApiEndpoints.notifications}/$id';

      final response = await NetworkAPIManager.instance.delete(endpoint);

      if (response.success) {
        print("✅ Successfully deleted notification: $id");
      } else {
        print(
          "❌ API Error deleting notification: ${response.statusCode} - ${response.message}",
        );
        throw Exception(
          'Failed to delete notification: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error deleting notification: $e");
      throw Exception('Failed to delete notification: $e');
    }
  }
}
