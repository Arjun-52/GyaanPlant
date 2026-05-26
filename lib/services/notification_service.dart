import 'package:firebase_messaging/firebase_messaging.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import 'package:flutter/foundation.dart';

/// Service for handling Firebase Cloud Messaging permissions and token management
class NotificationService {
  static String? _currentFCMToken;

  /// Request notification permissions for Firebase Cloud Messaging
  /// Handles all permission states and platform compatibility
  static Future<bool> requestNotificationPermissions() async {
    try {
      print("🔔 Requesting notification permissions...");

      // Request notification permission
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );

      // Handle different permission states
      return _handlePermissionStatus(settings);
    } catch (e) {
      print("❌ Error requesting notification permissions: $e");
      return false;
    }
  }

  /// Handle permission status and provide user feedback
  static bool _handlePermissionStatus(NotificationSettings settings) {
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        print("✅ Notification permissions granted");
        return true;

      case AuthorizationStatus.provisional:
        print("⚠️ Provisional notification permissions granted");
        return true;

      case AuthorizationStatus.denied:
        print("❌ Notification permissions denied");
        _showPermissionDeniedMessage();
        return false;

      case AuthorizationStatus.notDetermined:
        print("❓ Notification permissions not determined");
        return false;
    }
  }

  /// Show user-friendly message for denied permissions
  static void _showPermissionDeniedMessage() {
    if (kDebugMode) {
      print("📱 To enable notifications:");
      print("   Android: Go to Settings > Apps > GyaanPlant > Notifications");
      print("   iOS: Go to Settings > Notifications > GyaanPlant");
    }
  }

  /// Check current notification permission status
  static Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print("❌ Error checking notification status: $e");
      return false;
    }
  }

  /// Save FCM token to database
  static Future<void> saveFCMTokenToDatabase(String token) async {
    if (!NetworkAPIManager.isInitialized) {
      debugPrint("Skipping FCM save: NetworkAPIManager not initialized");
      return;
    }

    try {
      debugPrint("Saving token");
      print("💾 Saving FCM token to database: $token");

      final response = await NetworkAPIManager.instance.post(
        ApiEndpoints.fcmToken,
        data: {'fcmToken': token},
      );

      if (response.success) {
        print("✅ FCM Token successfully saved to database");
      } else {
        print(
          "❌ Failed to save FCM token: ${response.statusCode} - ${response.message}",
        );
      }
    } catch (e) {
      print("❌ Error saving FCM token to database: $e");
    }
  }

  /// Get FCM token for the device
  /// Stores token and provides refresh listener
  static Future<String?> getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();

      // Store current token
      _currentFCMToken = token;

      print("🔑 FCM Token retrieved: $token");
      print("📱 Token length: ${token?.length ?? 0} characters");

      // Save token to database immediately
      if (token != null) {
        await saveFCMTokenToDatabase(token);
      }

      return token;
    } catch (e) {
      print("❌ Error getting FCM token: $e");
      return null;
    }
  }

  /// Get current stored FCM token
  static String? get currentFCMToken => _currentFCMToken;

  /// Initialize FCM token listener for refresh events
  static void _initializeTokenListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      if (token.isNotEmpty) {
        _currentFCMToken = token;
        print("🔄 FCM Token refreshed: $token");

        // Save new token to database
        saveFCMTokenToDatabase(token);
      }
    });

    print("🎧 FCM token listener initialized");
  }

  /// Initialize notification service and request permissions
  static Future<void> initialize() async {
    try {
      print("🔔 Initializing notification service...");

      // Request permissions on app start
      await requestNotificationPermissions();

      // Get initial FCM token
      await getFCMToken();

      // Initialize token refresh listener
      _initializeTokenListener();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap (when app is opened from notification)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      print("🔔 Notification service initialized successfully");
    } catch (e) {
      print("❌ Error initializing notification service: $e");
    }
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    try {
      final title = message.notification?.title ?? 'No Title';
      final body = message.notification?.body ?? 'No Body';
      final data = message.data;

      print("📱 Received foreground message:");
      print("   Message ID: ${message.messageId}");
      print("   Title: $title");
      print("   Body: $body");
      print("   Data: $data");
      print("   Sent time: ${message.sentTime}");
      print("   From: ${message.from}");

      // TODO: Display in-app notification
      // TODO: Handle custom data payload
    } catch (e) {
      print("❌ Error handling foreground message: $e");
    }
  }

  /// Handle notification tap (when user opens notification)
  static void _handleNotificationTap(RemoteMessage message) {
    try {
      final title = message.notification?.title ?? 'No Title';
      final body = message.notification?.body ?? 'No Body';
      final data = message.data;

      print("🔔 Notification tapped:");
      print("   Message ID: ${message.messageId}");
      print("   Title: $title");
      print("   Body: $body");
      print("   Data: $data");
      print("   From: ${message.from}");

      // TODO: Navigate to specific screen based on notification data
      // TODO: Handle deep linking from notification
    } catch (e) {
      print("❌ Error handling notification tap: $e");
    }
  }

  /// Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print("🔔 Received background message: ${message.messageId}");
    // TODO: Handle background notification processing
  }
}
