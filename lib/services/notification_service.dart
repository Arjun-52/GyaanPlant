import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/auth_cache.dart';

/// Service for handling Firebase Cloud Messaging permissions, listeners, and
/// authenticated token registration.
///
/// Lifecycle:
///   1. `initialize()` — call from `main()`. Requests OS permission, wires up
///      foreground/background/tap listeners, and starts the token-refresh
///      stream. Does NOT contact the backend. Safe before login.
///   2. `registerFCMTokenWithBackend()` — call AFTER login (and on cold start
///      if a stored token exists). Fetches the FCM token and POSTs it to the
///      backend. No-op when the user is not authenticated.
class NotificationService {
  static const _tag = 'NotificationService';

  static String? _currentFCMToken;
  static bool _listenersInitialized = false;

  static String? get currentFCMToken => _currentFCMToken;

  /// Initialize notification listeners and request OS permissions.
  ///
  /// Pre-auth safe — never POSTs to the backend.
  static Future<void> initialize() async {
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
  /// No-op when `AuthCache.token` is null — prevents 401s on cold start.
  /// Call after a successful login and once on app start if a saved auth token
  /// is restored.
  static Future<void> registerFCMTokenWithBackend() async {
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

  /// Check current notification permission status
  static Future<bool> areNotificationsEnabled() async {
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

  // ── Private ────────────────────────────────────────────────────────────

  static Future<bool> _requestNotificationPermissions() async {
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

  static Future<void> _saveFCMTokenToDatabase(String token) async {
    try {
      final response = await NetworkAPIManager.instance.post(
        ApiEndpoints.fcmToken,
        data: {'fcmToken': token},
      );
      if (response.success) {
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

  static void _handleTokenRefresh(String token) {
    if (token.isEmpty) return;
    _currentFCMToken = token;
    AppLogger.info(_tag, 'FCM token refreshed');
    // Refresh is meaningful only when the user is logged in; the helper
    // bails out otherwise.
    if (AuthCache.token != null) {
      _saveFCMTokenToDatabase(token);
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info(
      _tag,
      'Foreground message: ${message.notification?.title ?? "(no title)"}',
    );
    // TODO: surface in-app notification.
  }

  static void _handleNotificationTap(RemoteMessage message) {
    AppLogger.info(_tag, 'Notification tapped: ${message.messageId}');
    // TODO: deep-link based on message.data.
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    AppLogger.info(_tag, 'Background message: ${message.messageId}');
  }
}
