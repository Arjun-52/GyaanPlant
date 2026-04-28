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
    print("🌍 FINAL API URL: $url");
    print("🔍 ENDPOINT: $endpoint");
    print("🌐 BASE URL: ${ApiConfig.baseUrl}");
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

      // Handle specific error codes
      switch (response.statusCode) {
        case 400:
          errorMessage = 'Bad request: Invalid data provided';
          break;
        case 401:
          errorMessage = 'Unauthorized: Invalid or expired token';
          break;
        case 403:
          errorMessage = 'Forbidden: Insufficient permissions';
          break;
        case 404:
          errorMessage = 'Not found: The requested resource does not exist';
          break;
        case 408:
          errorMessage = 'Request timeout: Server took too long to respond';
          break;
        case 429:
          errorMessage = 'Too many requests: Rate limit exceeded';
          break;
        case 500:
          errorMessage = 'Internal server error: Please try again later';
          break;
        case 502:
          errorMessage = 'Bad gateway: Server is temporarily unavailable';
          break;
        case 503:
          errorMessage = 'Service unavailable: Server is down for maintenance';
          break;
        default:
          errorMessage = 'Request failed with status: ${response.statusCode}';
      }

      // Try to extract more detailed error message from response body
      try {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              errorData['detail'] ??
              errorMessage;
        }
      } catch (_) {
        // If response body is not valid JSON, use the body directly if it's not empty
        if (response.body.isNotEmpty && response.body.length < 200) {
          errorMessage = response.body;
        }
      }

      throw Exception(errorMessage);
    }
  }
}
