import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/tpo_role_models/dashboard_model.dart';
import 'package:gyaanplant/network/auth_cache.dart';
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
  List<UpcomingDrive> drives = [];

  // College information
  String collegeName = "Loading...";

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  // Convenience getters for UI
  bool get hasData =>
      totalStudents > 0 ||
      activeDrives > 0 ||
      weeklyOffers > 0 ||
      studentsPlaced > 0 ||
      drives.isNotEmpty;
  bool get hasError => _errorMessage != null;

  /// Fetch dashboard data from API with safe JSON parsing
  /// Shows loading state during initial load
  Future<void> fetchDashboardData() async {
    print("🚀 API CALL STARTED");

    // Log current token for debugging
    final token = AuthCache.token;
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
        print("� RAW result.data: ${result.data}");
        print("📦 TYPE of result.data: ${result.data.runtimeType}");

        if (result.data is Map<String, dynamic>) {
          print("📦 KEYS: ${(result.data as Map<String, dynamic>).keys}");
        }

        if (result.data != null) {
          // SAFE PARSING - Handle both nested and direct response structures
          Map<String, dynamic> data = {};
          Map<String, dynamic> summary = {};
          List<dynamic> upcomingDrives = [];

          // Check if response is nested or direct
          if (result.data is Map<String, dynamic>) {
            final response = result.data as Map<String, dynamic>;

            // Handle nested structure: { success, data }
            if (response.containsKey('data') &&
                response['data'] is Map<String, dynamic>) {
              print("📦 DETECTED NESTED STRUCTURE: { data: {...} }");
              data = response['data'] as Map<String, dynamic>;
            }
            // Handle direct structure: { success, summary, upcomingDrives }
            else if (response.containsKey('summary') ||
                response.containsKey('upcomingDrives')) {
              print(
                "📦 DETECTED DIRECT STRUCTURE: { summary, upcomingDrives }",
              );
              data = response;
            }
            // Fallback - use response as data
            else {
              print("📦 FALLBACK - USING RESPONSE AS DATA");
              data = response;
            }
          } else {
            print("❌ ERROR: result.data is not a Map<String, dynamic>");
            _errorMessage = "Invalid API structure - expected JSON object";
            return;
          }

          // Extract summary safely
          if (data.containsKey('summary') &&
              data['summary'] is Map<String, dynamic>) {
            summary = data['summary'] as Map<String, dynamic>;
          } else {
            print("⚠️ WARNING: No valid 'summary' key found in data");
          }

          // Extract upcomingDrives safely
          if (data.containsKey('upcomingDrives') &&
              data['upcomingDrives'] is List) {
            upcomingDrives = data['upcomingDrives'] as List<dynamic>;
          } else {
            print("⚠️ WARNING: No valid 'upcomingDrives' key found in data");
          }

          print("📊 FINAL PARSED DATA: $data");
          print("📊 SUMMARY: $summary");
          print("📊 UPCOMING DRIVES: $upcomingDrives");
          print("📊 DRIVES COUNT: ${upcomingDrives.length}");

          // SAFE DATA EXTRACTION - Use null-aware operators and type checking
          activeDrives = summary['activeDrives'] is int
              ? summary['activeDrives']
              : 0;
          closingSoon = summary['closingSoon'] is int
              ? summary['closingSoon']
              : 0;
          totalStudents = summary['totalStudents'] is int
              ? summary['totalStudents']
              : 0;
          placementRate = summary['placementRate'] is num
              ? (summary['placementRate'] as num).toDouble()
              : 0.0;
          offersExtended = summary['offersExtended'] is int
              ? summary['offersExtended']
              : 0;
          weeklyOffers = summary['weeklyOffers'] is int
              ? summary['weeklyOffers']
              : 0;

          // SAFE DRIVES PARSING - Type-safe list mapping
          drives = upcomingDrives
              .where((e) => e is Map<String, dynamic>)
              .map((e) => UpcomingDrive.fromJson(e as Map<String, dynamic>))
              .toList();

          print("✅ STORED VALUES:");
          print("ActiveDrives: $activeDrives");
          print("TotalStudents: $totalStudents");
          print("PlacementRate: $placementRate");
          print("Drives Length: ${drives.length}");

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
      _errorMessage = "Parsing error: ${e.toString()}";

      // Reset fields on parsing error to prevent stale data
      print("⚠️ Parsing error - resetting data fields");
      _resetData();
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

  /// Fetch college name dynamically using collegeId from user profile
  Future<void> fetchCollegeName() async {
    print("🏫 Fetching college name...");

    try {
      final userRes = await ApiService().auth.getCurrentUser();

      print("👤 FULL RESPONSE: $userRes");

      final userData = userRes.data;

      print("👤 USER DATA: $userData");

      final college = userData?.college;

      print("🏫 College object: $college");

      if (college == null) {
        collegeName = "No College Assigned";
      } else {
        collegeName = college.toString();
      }

      print("🏫 Final College Name: $collegeName");
    } catch (e, stack) {
      print("💥 ERROR: $e");
      print("📍 STACK: $stack");
      collegeName = "Error loading college";
    }

    notifyListeners();
  }

  /// Initialize ViewModel - called when screen is first created
  void initialize() {
    print("🧠 ViewModel initialize() called");
    // Auto-fetch data when ViewModel is created
    fetchDashboardData();
    fetchCollegeName();
  }
}
