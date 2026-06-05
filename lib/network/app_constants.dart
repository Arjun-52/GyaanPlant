import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  static final String baseUrl = (() {
    if (kIsWeb) return 'http://192.168.10.64:5000';
    try {
      if (Platform.isAndroid) return 'http://192.168.10.64:5000';
      if (Platform.isIOS) return 'http://192.168.10.64:5000';
    } catch (_) {}
    return 'http://192.168.10.64:5000';
  })();

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Storage keys (mirrors LocalStorageService)
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';
}
