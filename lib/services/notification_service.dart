import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/auth_cache.dart';

/// Firebase Cloud Messaging permissions, listeners, and authenticated token
/// registration.
///
/// Singleton — access via `NotificationService.instance`.
///
/// Lifecycle:
///   1. `instance.initialize()` — called from `main()`. Requests OS
///      permission, wires up foreground/background/tap listeners, and starts
///      the token-refresh stream. Pre-auth safe — never contacts the backend.
///   2. `instance.registerFCMTokenWithBackend()` — called AFTER login (and on
///      cold start if a stored token exists). Fetches the FCM token and
///      POSTs it to the backend if it has changed since the last successful
///      save. No-op when the user is not authenticated.
///   3. `instance.clearSavedTokenCache()` — called on logout so a subsequent
///      login by a different user re-registers their device.
class NotificationService {
  static const _tag = 'NotificationService';

  static final NotificationService instance = NotificationService._();
  NotificationService._();

  String? _currentFCMToken;
  String? _lastSavedToken;
  bool _listenersInitialized = false;

  Future<void> initialize() async {
    try {
      await _requestNotificationPermissions();

      if (!_listenersInitialized) {
        FirebaseMessaging.instance.onTokenRefresh.listen(_handleTokenRefresh);
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
        _listenersInitialized = true;
      }

      AppLogger.info(_tag, 'Notification service initialized');
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to initialize notification service', e, st);
    }
  }

  /// Fetch the current FCM token and POST it to the backend.
  ///
  /// No-op when `AuthCache.token` is null. De-duplicates against
  /// `_lastSavedToken` so repeated calls with the same token make at most
  /// one backend POST.
  Future<void> registerFCMTokenWithBackend() async {
    if (AuthCache.token == null) {
      AppLogger.debug(_tag, 'Skipping FCM registration — user not authenticated');
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        AppLogger.warning(_tag, 'FCM token is null — cannot register');
        return;
      }

      _currentFCMToken = token;
      await _saveFCMTokenToDatabase(token);
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to register FCM token', e, st);
    }
  }

  /// Drop the de-dup cache so the next `registerFCMTokenWithBackend` call
  /// will POST regardless. Call on logout.
  void clearSavedTokenCache() {
    _lastSavedToken = null;
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to check notification status', e, st);
      return false;
    }
  }

  @visibleForTesting
  void reset() {
    _currentFCMToken = null;
    _lastSavedToken = null;
    _listenersInitialized = false;
  }

  // ── Private ────────────────────────────────────────────────────────────

  Future<bool> _requestNotificationPermissions() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          AppLogger.info(_tag, 'Notification permissions granted');
          return true;
        case AuthorizationStatus.provisional:
          AppLogger.info(_tag, 'Provisional notification permissions granted');
          return true;
        case AuthorizationStatus.denied:
          AppLogger.warning(_tag, 'Notification permissions denied');
          return false;
        case AuthorizationStatus.notDetermined:
          AppLogger.warning(_tag, 'Notification permissions not determined');
          return false;
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Error requesting notification permissions', e, st);
      return false;
    }
  }

  Future<void> _saveFCMTokenToDatabase(String token) async {
    if (token == _lastSavedToken) {
      AppLogger.debug(_tag, 'FCM token unchanged — skipping POST');
      return;
    }

    try {
      final response = await NetworkAPIManager.instance.post(
        ApiEndpoints.fcmToken,
        data: {'fcmToken': token},
      );
      if (response.success) {
        _lastSavedToken = token;
        AppLogger.info(_tag, 'FCM token saved to backend');
      } else {
        AppLogger.warning(
          _tag,
          'Failed to save FCM token: ${response.statusCode}',
        );
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Error saving FCM token to backend', e, st);
    }
  }

  void _handleTokenRefresh(String token) {
    if (token.isEmpty) return;
    _currentFCMToken = token;
    AppLogger.info(_tag, 'FCM token refreshed');
    // Refresh is meaningful only when the user is logged in.
    if (AuthCache.token != null) {
      _saveFCMTokenToDatabase(token);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info(
      _tag,
      'Foreground message: ${message.notification?.title ?? "(no title)"}',
    );
    // TODO: surface in-app notification.
  }

  void _handleNotificationTap(RemoteMessage message) {
    AppLogger.info(_tag, 'Notification tapped: ${message.messageId}');
    // TODO: deep-link based on message.data.
  }
}

// Background isolate handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  AppLogger.info('NotificationService', 'Background message: ${message.messageId}');
}
