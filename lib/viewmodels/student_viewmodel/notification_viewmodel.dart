import 'package:flutter/foundation.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../../models/notification/notification_model.dart';
import '../../services/notification_api_service.dart';

/// ViewModel for managing notification state and operations
class NotificationViewModel extends ChangeNotifier {
  static const _tag = 'NotificationViewModel';

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasNotifications => _notifications.isNotEmpty;
  bool get hasError => _errorMessage != null;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.read).toList();

  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.read).toList();

  Future<void> initialize() => fetchNotifications();

  Future<void> fetchNotifications() async {
    _setLoading(true);
    _clearError();

    try {
      final notifications = await NotificationApiService.getNotifications();
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _notifications = notifications;
      _updateUnreadCount();
      AppLogger.info(
        _tag,
        'Loaded ${notifications.length} notifications (unread: $_unreadCount)',
      );
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchNotifications failed', e, st);
      _setError('Failed to load notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await NotificationApiService.markAsRead(notificationId);
      _updateNotificationReadStatus(notificationId, true);
      AppLogger.info(_tag, 'Marked notification as read: $notificationId');
    } catch (e, st) {
      AppLogger.error(_tag, 'markNotificationAsRead failed', e, st);
      _setError('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    _setLoading(true);
    _clearError();

    try {
      await NotificationApiService.markAllAsRead();
      _updateAllNotificationsReadStatus(true);
      AppLogger.info(_tag, 'Marked all notifications as read');
    } catch (e, st) {
      AppLogger.error(_tag, 'markAllAsRead failed', e, st);
      _setError('Failed to mark all notifications as read: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshNotifications() => fetchNotifications();

  Future<void> deleteNotification(String notificationId) async {
    try {
      await NotificationApiService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();
      AppLogger.info(_tag, 'Deleted notification: $notificationId');
    } catch (e, st) {
      AppLogger.error(_tag, 'deleteNotification failed', e, st);
      _setError('Failed to delete notification: $e');
    }
  }

  void clearError() => _clearError();

  Future<void> retry() => fetchNotifications();

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
    if (index == -1) return;
    final notification = _notifications[index];
    _notifications[index] = notification.copyWith(
      read: isRead,
      readAt: isRead ? DateTime.now() : null,
    );
    _updateUnreadCount();
    notifyListeners();
  }

  void _updateAllNotificationsReadStatus(bool isRead) {
    _notifications = _notifications
        .map(
          (n) => n.copyWith(
            read: isRead,
            readAt: isRead ? DateTime.now() : null,
          ),
        )
        .toList();
    _updateUnreadCount();
    notifyListeners();
  }
}
