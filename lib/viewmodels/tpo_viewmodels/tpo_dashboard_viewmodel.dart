import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/services/auth_service.dart';
import 'dart:math' as math;

/// TPO Dashboard ViewModel
/// Manages dashboard state and API calls with direct field access
class TpoDashboardViewModel extends ChangeNotifier {
  // Loading states
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Error handling
  String? _errorMessage;

  // Direct data fields (simplified structure)
  int activeDrives = 0;
  int closingSoon = 0;
  int totalStudents = 0;
  double placementRate = 0.0;
  int offersExtended = 0;
  int weeklyOffers = 0;
  int studentsPlaced = 0;
  List<Map<String, dynamic>> drives = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  // Convenience getters for UI
  bool get hasData => drives.isNotEmpty || activeDrives != 0;
  bool get hasError => _errorMessage != null;

  /// Fetch dashboard data from API with direct JSON parsing
  /// Shows loading state during initial load
  Future<void> fetchDashboardData() async {
    print("🚀 CALLING TPO DASHBOARD API");

    // Log current token for debugging
    final token = AuthService.token;
    print(
      "🔑 TOKEN: ${token != null ? 'Present (${token.length} chars)' : 'MISSING'}",
    );
    if (token != null) {
      print(
        "🔑 TOKEN PREFIX: ${token.substring(0, math.min(20, token.length))}...",
      );
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print("🌐 API ENDPOINT: /api/v1/dashboard/tpo");

      final result = await ApiService().tpo.getDashboard();
      print("📦 RESPONSE STATUS: ${result.isSuccess ? 'SUCCESS' : 'FAILED'}");

      if (result.isSuccess) {
        print("📊 RAW RESPONSE DATA: ${result.data}");

        if (result.data != null) {
          // Extract data using correct JSON path
          final response = result.data as Map<String, dynamic>;
          final data = response['data'] as Map<String, dynamic>? ?? {};
          final summary = data['summary'] as Map<String, dynamic>? ?? {};
          final upcomingDrives = data['upcomingDrives'] as List<dynamic>? ?? [];

          print("✅ CORRECT DATA PATH EXTRACTION:");
          print("   - DATA: $data");
          print("   - SUMMARY: $summary");
          print("   - UPCOMING DRIVES: $upcomingDrives");
          print("   - UPCOMING DRIVES COUNT: ${upcomingDrives.length}");

          // Store data in ViewModel fields
          activeDrives = summary['activeDrives'] ?? 0;
          closingSoon = summary['closingSoon'] ?? 0;
          totalStudents = summary['totalStudents'] ?? 0;
          placementRate = (summary['placementRate'] ?? 0).toDouble();
          offersExtended = summary['offersExtended'] ?? 0;
          weeklyOffers = summary['weeklyOffers'] ?? 0;
          studentsPlaced = summary['studentsPlaced'] ?? 0;

          // Fix drives parsing with safe casting
          drives = upcomingDrives
              .map((e) => e as Map<String, dynamic>)
              .toList();

          print("✅ DATA STORED IN VIEWMODEL:");
          print("   - Active Drives: $activeDrives");
          print("   - Closing Soon: $closingSoon");
          print("   - Total Students: $totalStudents");
          print("   - Placement Rate: $placementRate");
          print("   - Weekly Offers: $weeklyOffers");
          print("   - Students Placed: $studentsPlaced");
          print("   - Drives Count: ${drives.length}");

          if (drives.isNotEmpty) {
            print("   - FIRST DRIVE: ${drives.first}");
          }

          print("✅ DASHBOARD DATA STORED SUCCESSFULLY");
          _errorMessage = null;
        } else {
          print("❌ RESULT DATA IS NULL");
          _errorMessage = 'API returned null data';
        }
      } else {
        print("❌ API ERROR: ${result.error?.message}");
        _errorMessage = result.error?.message ?? 'Failed to load dashboard';
      }
    } catch (e) {
      print("💥 EXCEPTION: $e");
      print("📍 STACK TRACE: ${StackTrace.current}");
      _errorMessage = e.toString();

      // Don't reset fields immediately on error - only if API fails consistently
      print("⚠️ Error occurred but keeping existing data for retry");
    } finally {
      _isLoading = false;
      print(
        "🔔 notifyListeners() called - isLoading=$_isLoading, hasData=$hasData, errorMessage=$_errorMessage",
      );
      notifyListeners(); // Called AFTER assigning values
    }
  }

  /// Refresh dashboard data (for pull-to-refresh)
  /// Shows refresh indicator but not main loading state
  Future<void> refreshDashboardData() async {
    // Set refresh state
    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API service
      await fetchDashboardData();
      _errorMessage = null;
    } catch (e) {
      // Handle errors (don't overwrite existing data on refresh error)
      _errorMessage = e.toString();
    } finally {
      // Stop refresh
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Reset all data fields (called only when needed)
  void _resetData() {
    activeDrives = 0;
    closingSoon = 0;
    totalStudents = 0;
    placementRate = 0.0;
    offersExtended = 0;
    weeklyOffers = 0;
    studentsPlaced = 0;
    drives = [];
    print("🔄 Data fields reset to defaults");
  }

  /// Retry fetching data after error
  Future<void> retryFetch() async {
    // Reset data on explicit retry
    _resetData();
    await fetchDashboardData();
  }

  /// Clear error message (called when user dismisses error)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get formatted placement rate as percentage string
  String get placementRateText {
    final rate = placementRate;
    if (rate == 0) return '0%';
    return '${rate.toStringAsFixed(1)}%';
  }

  /// Get formatted weekly offers text
  String get weeklyOffersText {
    final offers = weeklyOffers;
    if (offers == 0) return 'No offers this week';
    return '+$offers offers this week';
  }

  /// Check if there are any upcoming drives
  bool get hasUpcomingDrives => drives.isNotEmpty;

  /// Debug method to test API call directly
  Future<void> debugApiCall() async {
    print("🔍 DEBUG: Testing TPO Dashboard API call directly");

    try {
      final result = await ApiService().tpo.getDashboard();
      print("🔍 DEBUG: API Result - Success: ${result.isSuccess}");
      print("🔍 DEBUG: API Result - Data: ${result.data}");
      print("🔍 DEBUG: API Result - Error: ${result.error?.message}");

      if (result.isSuccess && result.data != null) {
        final response = result.data as Map<String, dynamic>;
        print("🔍 DEBUG: Response keys: ${response.keys.toList()}");

        if (response.containsKey('data')) {
          final data = response['data'] as Map<String, dynamic>;
          print("🔍 DEBUG: Data keys: ${data.keys.toList()}");

          if (data.containsKey('summary')) {
            final summary = data['summary'] as Map<String, dynamic>;
            print("🔍 DEBUG: Summary keys: ${summary.keys.toList()}");
            print("🔍 DEBUG: Summary content: $summary");
          } else {
            print("❌ DEBUG: No 'summary' key found in data");
          }

          if (data.containsKey('upcomingDrives')) {
            final drives = data['upcomingDrives'] as List<dynamic>;
            print("🔍 DEBUG: Upcoming drives count: ${drives.length}");
            if (drives.isNotEmpty) {
              print("🔍 DEBUG: First drive: ${drives.first}");
            }
          } else {
            print("❌ DEBUG: No 'upcomingDrives' key found in data");
          }
        } else {
          print("❌ DEBUG: No 'data' key found in response");
        }
      }
    } catch (e) {
      print("💥 DEBUG: Exception in API call: $e");
    }
  }

  /// Initialize ViewModel - called when screen is first created
  void initialize() {
    // Auto-fetch data when ViewModel is created
    fetchDashboardData();
  }
}
