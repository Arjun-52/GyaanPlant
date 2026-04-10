import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

/// ApiService handles all API communications with the backend.
/// This is a basic implementation that can be extended with actual endpoints.
class ApiService {
  ApiService._(); // Private constructor to prevent instantiation

  static const String baseUrl = 'https://api.example.com'; // Replace with actual base URL
  static const Duration timeout = Duration(seconds: 30);

  /// Generic GET request method
  static Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic POST request method
  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(data),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic PUT request method
  static Future<Map<String, dynamic>> _put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(data),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic DELETE request method
  static Future<void> _delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'))
          .timeout(timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Example API methods (these would be implemented with actual endpoints)

  /// Fetches a user by ID
  static Future<UserModel> getUser(String userId) async {
    final data = await _get('/users/$userId');
    return UserModel.fromJson(data);
  }

  /// Creates a new user
  static Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final data = await _post('/users', userData);
    return UserModel.fromJson(data);
  }

  /// Updates an existing user
  static Future<UserModel> updateUser(String userId, Map<String, dynamic> userData) async {
    final data = await _put('/users/$userId', userData);
    return UserModel.fromJson(data);
  }

  /// Deletes a user
  static Future<void> deleteUser(String userId) async {
    await _delete('/users/$userId');
  }

  /// Fetches a list of users
  static Future<List<UserModel>> getUsers() async {
    final data = await _get('/users');
    final List<dynamic> usersList = data['users'] as List<dynamic>;
    return usersList.map((user) => UserModel.fromJson(user as Map<String, dynamic>)).toList();
  }
}
