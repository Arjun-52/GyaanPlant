import 'package:dio/dio.dart';
import 'package:gyaanplant/network/api_endpoints.dart';

import '../../data/services/local_storage_service.dart';
import '../auth_cache.dart';

class AuthInterceptor extends Interceptor {
  // Set this once at app startup (e.g. in main.dart) to handle forced logout
  static void Function()? onUnauthorized;

  static const _skipList = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.forgotPassword,
    ApiEndpoints.resetPassword,
  ];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final shouldSkip = _skipList.any((e) => options.path.contains(e));

    if (!shouldSkip) {
      final token = AuthCache.token;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      AuthCache.token = null;
      await LocalStorageService.clearToken();
      onUnauthorized?.call();
    }

    super.onError(err, handler);
  }
}
