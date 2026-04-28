import 'dart:io';
import 'package:dio/dio.dart';
import 'api_response.dart';
import 'app_constants.dart';
import 'network_config.dart';

class NetworkAPIManager {
  static NetworkAPIManager? _instance;
  late final Dio _dio;
  final NetworkConfig _config;
  bool _isInitialized = false;

  static final List<CancelToken> _activeCancelTokens = [];

  NetworkAPIManager._(this._config) {
    _initialize();
  }

  static void initialize({NetworkConfig? config}) {
    if (_instance != null) {
      throw StateError(
        'NetworkAPIManager already initialized. Call reset() first.',
      );
    }
    _instance = NetworkAPIManager._(config ?? NetworkConfig.defaultConfig());
  }

  static NetworkAPIManager get instance {
    if (_instance == null) {
      throw StateError(
        'NetworkAPIManager not initialized. Call NetworkAPIManager.initialize() first.',
      );
    }
    return _instance!;
  }

  static void reset() {
    _instance?._dio.close();
    _instance = null;
  }

  static bool get isInitialized => _instance != null;

  void _initialize() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        connectTimeout: Duration(milliseconds: _config.connectTimeout),
        receiveTimeout: Duration(milliseconds: _config.receiveTimeout),
        sendTimeout: Duration(milliseconds: _config.sendTimeout),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.addAll(_config.interceptors);

    if (_config.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          logPrint: (obj) => debugLog('[API] $obj'),
        ),
      );
    }

    _isInitialized = true;
  }

  // ── Public HTTP methods ────────────────────────────────────────────────

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    final token = cancelToken ?? CancelToken();
    _activeCancelTokens.add(token);
    return _perform(
      () => _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: token,
      ),
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    final token = cancelToken ?? CancelToken();
    _activeCancelTokens.add(token);
    return _perform(
      () => _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: token,
      ),
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    final token = cancelToken ?? CancelToken();
    _activeCancelTokens.add(token);
    return _perform(
      () => _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: token,
      ),
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    final token = cancelToken ?? CancelToken();
    _activeCancelTokens.add(token);
    return _perform(
      () => _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: token,
      ),
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    final token = cancelToken ?? CancelToken();
    _activeCancelTokens.add(token);
    return _perform(
      () => _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: token,
      ),
      fromJson: fromJson,
    );
  }

  static void cancelAllRequests() {
    for (final t in _activeCancelTokens) {
      if (!t.isCancelled) t.cancel('Cancelled by user');
    }
    _activeCancelTokens.clear();
  }

  void dispose() => _dio.close(force: true);

  // ── Core request handler ───────────────────────────────────────────────

  Future<ApiResponse<T>> _perform<T>(
    Future<Response> Function() request, {
    T Function(dynamic)? fromJson,
    int retryCount = 0,
  }) async {
    try {
      final response = await request();
      return _handleResponse<T>(response, fromJson: fromJson);
    } on DioException catch (e) {
      if (retryCount < AppConstants.maxRetries && _shouldRetry(e)) {
        await Future.delayed(AppConstants.retryDelay * (retryCount + 1));
        return _perform(request, fromJson: fromJson, retryCount: retryCount + 1);
      }
      final error = _mapDioError(e);
      return ApiResponse.failure(
        error: error,
        statusCode: e.response?.statusCode ?? 500,
      );
    } on SocketException {
      return ApiResponse.failure(
        error: const ApiError(
          code: 'NO_INTERNET',
          message: 'No internet connection.',
        ),
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.failure(
        error: ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred.',
          details: e.toString(),
        ),
        statusCode: 500,
      );
    }
  }

  ApiResponse<T> _handleResponse<T>(
    Response response, {
    T Function(dynamic)? fromJson,
  }) {
    final statusCode = response.statusCode ?? 500;

    if (statusCode >= 200 && statusCode < 300) {
      final raw = response.data;
      T? parsed;
      if (fromJson != null && raw != null) {
        parsed = fromJson(raw);
      } else {
        parsed = raw as T?;
      }
      return ApiResponse.success(
        data: parsed as T,
        statusCode: statusCode,
      );
    }

    final error = _parseErrorBody(response.data);
    return ApiResponse.failure(error: error, statusCode: statusCode);
  }

  // ── Error helpers ──────────────────────────────────────────────────────

  ApiError _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          code: 'TIMEOUT',
          message: 'Request timed out. Please check your connection.',
        );
      case DioExceptionType.connectionError:
        return const ApiError(
          code: 'NETWORK_ERROR',
          message: 'Network connection failed.',
        );
      case DioExceptionType.badResponse:
        return _parseErrorBody(e.response?.data);
      default:
        return ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred.',
          details: e.message,
        );
    }
  }

  ApiError _parseErrorBody(dynamic body) {
    if (body is Map<String, dynamic>) {
      return ApiError.fromJson(body);
    }
    return ApiError(
      code: 'SERVER_ERROR',
      message: 'Server error occurred.',
      details: body?.toString(),
    );
  }

  bool _shouldRetry(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        return code != null && code >= 500;
      default:
        return false;
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('NetworkAPIManager is not properly initialized.');
    }
  }

  // ignore: avoid_print
  void debugLog(String msg) => print(msg);
}
