import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';

/// Base API service for handling common HTTP operations
class BaseApiService {
  static const String baseUrl = 'https://backend.gyaanplant.in';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  ///  BUILD URL
  static Uri _buildUrl(String endpoint) {
    final url = '$baseUrl${endpoint.startsWith('/') ? endpoint : '/$endpoint'}';
    print("🚀 API Call: $url");
    return Uri.parse(url);
  }

  ///  GET
  static Future<http.Response> get(String endpoint) async {
    final token = await LocalStorageService.getToken();

    final headers = Map<String, String>.from(_headers);

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

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

    final headers = Map<String, String>.from(_headers);

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http
          .post(_buildUrl(endpoint), headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      print('Network error in POST: ${e.toString()}');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// 🔥 PUT
  static Future<http.Response> put(String endpoint, dynamic data) async {
    final token = await LocalStorageService.getToken();

    final headers = Map<String, String>.from(_headers);

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

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

    final headers = Map<String, String>.from(_headers);

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

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
