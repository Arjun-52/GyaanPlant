import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gyaanplant/models/tpo_role_models/dashboard_model.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';

/// TPO Dashboard API Service
/// Handles all dashboard-related API calls
class TpoDashboardService {
  // Base URL - replace with your actual API base URL
  static const String baseUrl = 'http://10.0.2.2:5000';
  static const Duration timeout = Duration(seconds: 30);

  /// Fetch TPO Dashboard data from API
  /// GET /api/v1/dashboard/tpo
  static Future<TpoDashboardModel> fetchDashboardData() async {
    try {
      // Get auth token from local storage
      final token = await LocalStorageService.getToken();
      print("🔐 TOKEN:");
      print(token);

      // Make API request with authentication
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/v1/dashboard/tpo'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token', // Add JWT token
            },
          )
          .timeout(timeout);
      print("🌐 RAW RESPONSE:");
      print(response.body);

      // Handle different response codes
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return TpoDashboardModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // Token expired - clear and redirect to login
        await LocalStorageService.clearToken();
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied. Insufficient permissions.');
      } else if (response.statusCode == 404) {
        throw Exception('Dashboard data not found.');
      } else {
        throw Exception('Failed to load dashboard: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors and timeouts
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      } else {
        // Re-throw custom exceptions
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  /// Refresh dashboard data (same as fetch, but can be used for pull-to-refresh)
  static Future<TpoDashboardModel> refreshDashboardData() async {
    return fetchDashboardData();
  }
}
