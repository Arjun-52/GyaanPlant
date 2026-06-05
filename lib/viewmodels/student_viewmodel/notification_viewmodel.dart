import 'package:flutter/foundation.dart';
import '../../models/notification/notification_model.dart';
import '../../services/notification_api_service.dart';

/// ViewModel for managing notification state and operations
class NotificationViewModel extends ChangeNotifier {
  // State variables
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasNotifications => _notifications.isNotEmpty;
  bool get hasError => _errorMessage != null;
  
  // Get unread notifications
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((notification) => !notification.read).toList();
  
  // Get read notifications
  List<NotificationModel> get readNotifications => 
      _notifications.where((notification) => notification.read).toList();

  /// Initialize the ViewModel and fetch notifications
  Future<void> initialize() async {
    await fetchNotifications();
  }

  /// Fetch notifications from the API
  Future<void> fetchNotifications() async {
    print("🔔 NotificationViewModel: Fetching notifications...");
    
    _setLoading(true);
    _clearError();

    try {
      final notifications = await NotificationApiService.getNotifications();
      
      // Sort notifications by creation date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _notifications = notifications;
      _updateUnreadCount();
      
      print("✅ NotificationViewModel: Fetched ${notifications.length} notifications");
      print("📊 Unread count: $_unreadCount");
      
    } catch (e) {
      print("❌ NotificationViewModel: Error fetching notifications: $e");
      _setError('Failed to load notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Mark a specific notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    print("🔔 NotificationViewModel: Marking notification as read: $notificationId");
    
    try {
      // Call API to mark as read
      await NotificationApiService.markAsRead(notificationId);
      
      // Update local state
      _updateNotificationReadStatus(notificationId, true);
      
      print("✅ NotificationViewModel: Successfully marked notification as read");
      
    } catch (e) {
      print("❌ NotificationViewModel: Error marking notification as read: $e");
      _setError('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    print("🔔 NotificationViewModel: Marking all notifications as read");
    
    _setLoading(true);
    _clearError();

    try {
      // Call API to mark all as read
      await NotificationApiService.markAllAsRead();
      
      // Update local state
      _updateAllNotificationsReadStatus(true);
      
      print("✅ NotificationViewModel: Successfully marked all notifications as read");
      
    } catch (e) {
      print("❌ NotificationViewModel: Error marking all as read: $e");
      _setError('Failed to mark all notifications as read: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh notifications (pull-to-refresh functionality)
  Future<void> refreshNotifications() async {
    print("🔄 NotificationViewModel: Refreshing notifications...");
    await fetchNotifications();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    print("🗑️ NotificationViewModel: Deleting notification: $notificationId");
    
    try {
      // Call API to delete
      await NotificationApiService.deleteNotification(notificationId);
      
      // Remove from local state
      _notifications.removeWhere((notification) => notification.id == notificationId);
      _updateUnreadCount();
      
      print("✅ NotificationViewModel: Successfully deleted notification");
      
    } catch (e) {
      print("❌ NotificationViewModel: Error deleting notification: $e");
      _setError('Failed to delete notification: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Retry fetching notifications
  Future<void> retry() async {
    await fetchNotifications();
  }

  // Private helper methods

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _updateUnreadCount() {
    _unreadCount = unreadNotifications.length;
  }

  void _updateNotificationReadStatus(String notificationId, bool isRead) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = notification.copyWith(
        read: isRead,
        readAt: isRead ? DateTime.now() : null,
      );
      _updateUnreadCount();
      notifyListeners();
    }
  }

  void _updateAllNotificationsReadStatus(bool isRead) {
    _notifications = _notifications.map((notification) => 
      notification.copyWith(
        read: isRead,
        readAt: isRead ? DateTime.now() : null,
      )
    ).toList();
    _updateUnreadCount();
    notifyListeners();
  }

  @override
  void dispose() {
    print("🔔 NotificationViewModel: Disposed");
    super.dispose();
  }
}
