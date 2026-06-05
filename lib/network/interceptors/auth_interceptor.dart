import 'package:dio/dio.dart';
import 'package:gyaanplant/network/api_endpoints.dart';

import '../auth_cache.dart';

class AuthInterceptor extends Interceptor {
  // Set this once at app startup (e.g. in main.dart) to handle forced logout
  static void Function()? onUnauthorized;

  // ⚠️ TESTING: These endpoints are skipped temporarily for testing without auth
  // Remove 'ApiEndpoints.dashboardStudent' before production!
  static const _skipList = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.forgotPassword,
    ApiEndpoints.resetPassword,
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print("=== AUTH INTERCEPTOR DEBUG ===");
    print("URL: ${options.uri}");
    print("METHOD: ${options.method}");
    print("PATH: ${options.path}");

    final shouldSkip = _skipList.any((e) => options.path.contains(e));
    print("SHOULD SKIP AUTH: $shouldSkip");

    if (!shouldSkip) {
      final token = AuthCache.token;
      print("TOKEN FROM CACHE: $token");
      print("TOKEN IS NULL: ${token == null}");

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        print(
          "✅ AUTH HEADER ADDED: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...",
        );
      } else {
        print("❌ NO TOKEN FOUND - REQUEST WILL BE UNAUTHENTICATED");
      }
    } else {
      print("⏭️ SKIPPING AUTH FOR THIS REQUEST");
    }

    print("FINAL HEADERS: ${options.headers}");
    print("=== END INTERCEPTOR DEBUG ===");

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print("=== AUTH INTERCEPTOR ERROR DEBUG ===");
    print("ERROR TYPE: ${err.type}");
    print("STATUS CODE: ${err.response?.statusCode}");
    print("ERROR MESSAGE: ${err.message}");
    print("ERROR URL: ${err.requestOptions.uri}");
    print("RESPONSE DATA: ${err.response?.data}");

    if (err.response?.statusCode == 401) {
      print("🚨 401 UNAUTHORIZED - CLEARING TOKEN");
      // Clear in-memory cache immediately
      AuthCache.token = null;
      // Trigger logout callback
      onUnauthorized?.call();
    } else if (err.response?.statusCode == 403) {
      print("🚫 403 FORBIDDEN - PERMISSION ISSUE");
    } else if (err.response?.statusCode == 500) {
      print("💥 500 SERVER ERROR - BACKEND ISSUE");
    }

    print("=== END INTERCEPTOR ERROR DEBUG ===");

    super.onError(err, handler);
  }
}
