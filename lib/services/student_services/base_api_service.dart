import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../../core/utils/app_logger.dart';
import '../../data/services/local_storage_service.dart';

class BaseApiService {
  static const Duration _timeout = AppConfig.httpTimeout;
  static const String _tag = 'BaseApiService';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Uri _buildUrl(String endpoint) {
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('${AppConfig.baseUrl}$path');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await LocalStorageService.getToken();
    final headers = Map<String, String>.from(_headers);
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  static Future<http.Response> get(String endpoint) async {
    AppLogger.debug(_tag, 'GET $endpoint');
    try {
      final response = await http
          .get(_buildUrl(endpoint), headers: await _authHeaders())
          .timeout(_timeout);
      return _handleResponse(endpoint, response);
    } on Exception catch (e) {
      AppLogger.error(_tag, 'GET $endpoint failed', e);
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> getWithHeaders(
    String endpoint,
    Map<String, String> headers,
  ) async {
    AppLogger.debug(_tag, 'GET $endpoint');
    try {
      final response = await http
          .get(_buildUrl(endpoint), headers: headers)
          .timeout(_timeout);
      return _handleResponse(endpoint, response);
    } on Exception catch (e) {
      AppLogger.error(_tag, 'GET $endpoint failed', e);
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> post(String endpoint, dynamic data) async {
    AppLogger.debug(_tag, 'POST $endpoint');
    try {
      final response = await http
          .post(
            _buildUrl(endpoint),
            headers: await _authHeaders(),
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return _handleResponse(endpoint, response);
    } on Exception catch (e) {
      AppLogger.error(_tag, 'POST $endpoint failed', e);
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> put(String endpoint, dynamic data) async {
    AppLogger.debug(_tag, 'PUT $endpoint');
    try {
      final response = await http
          .put(
            _buildUrl(endpoint),
            headers: await _authHeaders(),
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return _handleResponse(endpoint, response);
    } on Exception catch (e) {
      AppLogger.error(_tag, 'PUT $endpoint failed', e);
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    AppLogger.debug(_tag, 'DELETE $endpoint');
    try {
      final response = await http
          .delete(_buildUrl(endpoint), headers: await _authHeaders())
          .timeout(_timeout);
      return _handleResponse(endpoint, response);
    } on Exception catch (e) {
      AppLogger.error(_tag, 'DELETE $endpoint failed', e);
      throw Exception('Network error: $e');
    }
  }

  static http.Response _handleResponse(String endpoint, http.Response response) {
    AppLogger.debug(_tag, 'Response $endpoint → ${response.statusCode}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    String errorMessage = 'Request failed with status: ${response.statusCode}';
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map && errorData['message'] != null) {
        errorMessage = errorData['message'].toString();
      }
    } catch (_) {}

    AppLogger.warning(_tag, 'API error [$endpoint]: $errorMessage');
    throw Exception(errorMessage);
  }
}
