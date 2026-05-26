import 'package:flutter/foundation.dart';
import '../../data/services/api_service.dart';
import '../../models/tpo_role_models/tpo_notification_model.dart';
import '../../repositories/tpo_notification_repository.dart';

class TpoNotificationViewModel extends ChangeNotifier {
  final TpoNotificationRepository _repository = ApiService().tpoNotification;

  List<TpoNotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _totalNotifications = 0;
  int _currentPage = 1;
  static const int _limit = 15;
  bool _hasMore = true;

  // Getters
  List<TpoNotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  int get totalNotifications => _totalNotifications;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get hasError => _errorMessage != null;

  /// Dynamic unread count calculated from the loaded notifications list
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Fetch notifications with optional reset for initial load or pull-to-refresh
  Future<void> fetchNotifications({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _notifications = [];
      _hasMore = true;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (!_hasMore || _isLoadingMore || _isLoading) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final response = await _repository.getNotifications(
        page: _currentPage,
        limit: _limit,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        
        if (reset) {
          _notifications = data.notifications;
        } else {
          _notifications.addAll(data.notifications);
        }

        _totalNotifications = data.total;
        _hasMore = _notifications.length < _totalNotifications;
        if (_hasMore) {
          _currentPage++;
        }
        _errorMessage = null;
      } else {
        _errorMessage = response.error?.message ?? response.message ?? 'Failed to load notifications';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Mark a single notification as read using Optimistic UI updates
  Future<void> markNotificationAsRead(String id) async {
    final int index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    // 1. Capture current state for potential rollback
    final List<TpoNotificationModel> previousNotifications = List.from(_notifications);

    // 2. Optimistic UI update - instantly set isRead = true
    _notifications[index] = TpoNotificationModel(
      id: _notifications[index].id,
      title: _notifications[index].title,
      message: _notifications[index].message,
      isRead: true,
      createdAt: _notifications[index].createdAt,
    );
    _errorMessage = null;
    notifyListeners();
    debugPrint("Notification marked read");

    try {
      final response = await _repository.markNotificationRead(id);
      if (!response.isSuccess) {
        // Rollback on API failure
        _notifications = previousNotifications;
        _errorMessage = response.error?.message ?? response.message ?? 'Failed to mark notification as read';
        notifyListeners();
        throw Exception(_errorMessage);
      }
    } catch (e) {
      // Rollback on catch block
      _notifications = previousNotifications;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Mark all notifications as read on the backend using Optimistic UI updates
  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;

    // 1. Capture current state for potential rollback
    final List<TpoNotificationModel> previousNotifications = List.from(_notifications);

    // 2. Optimistic UI update - instantly set all to isRead = true
    _notifications = _notifications.map((n) {
      return TpoNotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        isRead: true,
        createdAt: n.createdAt,
      );
    }).toList();
    _errorMessage = null;
    notifyListeners();
    debugPrint("All notifications marked read");

    try {
      final response = await _repository.markAllNotificationsRead();
      if (!response.isSuccess) {
        // Rollback on API failure
        _notifications = previousNotifications;
        _errorMessage = response.error?.message ?? response.message ?? 'Failed to mark all as read';
        notifyListeners();
        throw Exception(_errorMessage);
      }
    } catch (e) {
      // Rollback on catch block
      _notifications = previousNotifications;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clear current errors
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
