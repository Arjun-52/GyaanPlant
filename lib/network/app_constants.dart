import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  static final String baseUrl = (() {
    if (kIsWeb) return 'https://backend.gyaanplant.co.in';
    try {
      if (Platform.isAndroid) return 'https://backend.gyaanplant.co.in';
      if (Platform.isIOS) return 'https://backend.gyaanplant.co.in';
    } catch (_) {}
    return 'https://backend.gyaanplant.co.in';
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
