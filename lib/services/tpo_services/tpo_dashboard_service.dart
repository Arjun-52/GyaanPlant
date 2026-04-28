import 'dart:convert';
import 'package:gyaanplant/models/tpo_role_models/dashboard_model.dart';
import 'package:gyaanplant/services/student_services/base_api_service.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';
import 'package:gyaanplant/config/api_config.dart';

/// TPO Dashboard API Service
/// Handles all dashboard-related API calls
class TpoDashboardService {
  // Using centralized ApiConfig for consistent base URL

  /// Fetch TPO Dashboard data from API
  /// GET /api/v1/dashboard/tpo
  static Future<TpoDashboardModel> fetchDashboardData() async {
    try {
      print("🌍 BASE URL: ${ApiConfig.baseUrl}");

      // Make API request using centralized BaseApiService
      final response = await BaseApiService.get('/api/v1/dashboard/tpo');

      print("🌐 RAW RESPONSE:");
      print(response.body);

      // Handle different response codes
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == false) {
          throw Exception(responseData['message'] ?? 'Unknown error');
        }
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
