import 'package:dio/dio.dart';
import 'app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/content_type_interceptor.dart';

class NetworkConfig {
  final String baseUrl;
  final int connectTimeout;
  final int receiveTimeout;
  final int sendTimeout;
  final List<Interceptor> interceptors;
  final bool enableLogging;

  NetworkConfig({
    required this.baseUrl,
    this.connectTimeout = AppConstants.connectTimeout,
    this.receiveTimeout = AppConstants.receiveTimeout,
    this.sendTimeout = AppConstants.sendTimeout,
    this.interceptors = const [],
    this.enableLogging = true,
  });

  static NetworkConfig defaultConfig() {
    return NetworkConfig(
      baseUrl: AppConstants.baseUrl,
      interceptors: [
        ContentTypeInterceptor(),
        AuthInterceptor(),
      ],
      enableLogging: true,
    );
  }
}
