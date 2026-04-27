import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';
import '../../config/api_config.dart';

/// Base API service for handling common HTTP operations
class BaseApiService {
  // Using centralized ApiConfig for consistent base URL

  ///  BUILD URL
  static Uri _buildUrl(String endpoint) {
    final url = ApiConfig.buildUrl(endpoint);
    print("🚀 API Call: $url");
    return Uri.parse(url);
  }

  ///  GET
  static Future<http.Response> get(String endpoint) async {
    final token = await LocalStorageService.getToken();

    final headers = token != null
        ? ApiConfig.buildAuthHeaders(token)
        : ApiConfig.headers;

    try {
      final response = await http.get(_buildUrl(endpoint), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  ///  GET with custom headers
  static Future<http.Response> getWithHeaders(
    String endpoint,
    Map<String, String> headers,
  ) async {
    try {
      final response = await http.get(_buildUrl(endpoint), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// 🔥 POST
  static Future<http.Response> post(String endpoint, dynamic data) async {
    final token = await LocalStorageService.getToken();

    final headers = token != null
        ? ApiConfig.buildAuthHeaders(token)
        : ApiConfig.headers;

    try {
      final response = await http
          .post(_buildUrl(endpoint), headers: headers, body: jsonEncode(data))
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } catch (e) {
      print('Network error in POST: ${e.toString()}');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// 🔥 PUT
  static Future<http.Response> put(String endpoint, dynamic data) async {
    final token = await LocalStorageService.getToken();

    final headers = token != null
        ? ApiConfig.buildAuthHeaders(token)
        : ApiConfig.headers;

    try {
      final response = await http.put(
        _buildUrl(endpoint),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// 🔥 DELETE
  static Future<http.Response> delete(String endpoint) async {
    final token = await LocalStorageService.getToken();

    final headers = token != null
        ? ApiConfig.buildAuthHeaders(token)
        : ApiConfig.headers;

    try {
      final response = await http.delete(_buildUrl(endpoint), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  ///  RESPONSE HANDLER
  static http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      String errorMessage =
          'Request failed with status: ${response.statusCode}';

      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (_) {}

      throw Exception(errorMessage);
    }
  }
}
