import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';

/// ApiService handles generic HTTP operations.
/// For student-specific endpoints use BaseApiService in services/student_services/.
class ApiService {
  ApiService._();

  static const String baseUrl = 'https://your-api-url.com';
  static const Duration _timeout = Duration(seconds: 30);

  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Builds headers, optionally injecting auth token
  static Future<Map<String, String>> _buildHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final token = await LocalStorageService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .get(uri, headers: await _buildHeaders())
        .timeout(_timeout);
    return _handleResponse(response);
  }

  /// POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .post(uri, headers: await _buildHeaders(), body: jsonEncode(body))
        .timeout(_timeout);
    return _handleResponse(response);
  }

  /// PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .put(uri, headers: await _buildHeaders(), body: jsonEncode(body))
        .timeout(_timeout);
    return _handleResponse(response);
  }

  /// DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .delete(uri, headers: await _buildHeaders())
        .timeout(_timeout);
    return _handleResponse(response);
  }

  /// Handles response and throws on non-2xx
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    String errorMessage =
        'Request failed with status: ${response.statusCode}';
    try {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      errorMessage = errorData['message']?.toString() ?? errorMessage;
    } catch (_) {}

    throw Exception(errorMessage);
  }
}
