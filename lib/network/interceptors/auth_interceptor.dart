import 'package:dio/dio.dart';
import 'package:gyaanplant/core/events/auth_event_bus.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/network/api_endpoints.dart';

import '../auth_cache.dart';

class AuthInterceptor extends Interceptor {
  static const _tag = 'AuthInterceptor';

  // ⚠️ TESTING: These endpoints are skipped temporarily for testing without auth
  // Remove 'ApiEndpoints.dashboardStudent' before production!
  static const _skipList = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.forgotPassword,
    ApiEndpoints.resetPassword,
  ];

  bool _isSkipped(String path) => _skipList.any(path.contains);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isSkipped(options.path)) {
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
  //
  // A 401 from a skip-listed endpoint (login, register, forgot/reset password)
  // is just "bad credentials" — must NOT clear the token cache or force logout,
  // otherwise an already-signed-in user typing a wrong password on a re-auth
  // form would be silently signed out.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 401 &&
        !_isSkipped(response.requestOptions.path)) {
      AppLogger.warning(_tag, '401 on authenticated request — clearing token');
      AuthCache.token = null;
      AuthEventBus.emit(const SessionExpired());
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
