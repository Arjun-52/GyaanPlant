import 'package:dio/dio.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/network/api_endpoints.dart';

import '../auth_cache.dart';

class AuthInterceptor extends Interceptor {
  static const _tag = 'AuthInterceptor';

  // Set once at app startup to handle forced logout.
  static void Function()? onUnauthorized;

  static const _skipList = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.forgotPassword,
    ApiEndpoints.resetPassword,
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final shouldSkip = _skipList.any((e) => options.path.contains(e));

    if (!shouldSkip) {
      final token = AuthCache.token;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        AppLogger.warning(
          _tag,
          'No token — request will be unauthenticated: ${options.path}',
        );
      }
    }

    super.onRequest(options, handler);
  }

  // NOTE: validateStatus allows status < 500, so 401 arrives here — NOT in
  // onError. We must handle session-expiry in onResponse.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 401) {
      AppLogger.warning(_tag, '401 Unauthorized — clearing token');
      AuthCache.token = null;
      onUnauthorized?.call();
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Fires only for status >= 500 (or network errors) due to validateStatus.
    final status = err.response?.statusCode;
    if (status != null && status >= 500) {
      AppLogger.error(_tag, '$status Server error: ${err.requestOptions.path}');
    }
    super.onError(err, handler);
  }
}
