import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/dashboard_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

/// TPO Dashboard ViewModel
/// Manages dashboard state and API calls
class TpoDashboardViewModel extends ChangeNotifier {
  // Loading states
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Data
  TpoDashboardModel? _dashboardData;

  // Error handling
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  TpoDashboardModel? get dashboardData => _dashboardData;
  String? get errorMessage => _errorMessage;

  // Convenience getters for UI
  bool get hasData => _dashboardData != null;
  bool get hasError => _errorMessage != null;

  // Get summary data safely
  DashboardSummary get summary =>
      _dashboardData?.data.summary ??
      DashboardSummary(
        activeDrives: 0,
        closingSoon: 0,
        totalStudents: 0,
        profileCompletion: 0,
        offersExtended: 0,
        weeklyOffers: 0,
        studentsPlaced: 0,
        placementRate: 0.0,
      );

  // Get upcoming drives safely
  List<UpcomingDrive> get upcomingDrives =>
      _dashboardData?.data.upcomingDrives ?? [];

  // Get department placement data safely
  List<DepartmentPlacement> get departmentPlacement =>
      _dashboardData?.data.departmentPlacement ?? [];

  /// Fetch dashboard data from API
  /// Shows loading state during initial load
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print("🚀 API CALL STARTED");

      final result = await ApiService().tpo.getDashboard();
      if (result.isSuccess) {
        _dashboardData = result.data;
      } else {
        throw Exception(result.error?.message ?? 'Failed to load dashboard');
      }
      _errorMessage = null;
    } catch (e) {
      print("❌ API ERROR:");
      print(e);

      _errorMessage = e.toString();
      _dashboardData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      final result = await ApiService().tpo.getDashboard();
      if (result.isSuccess) {
        _dashboardData = result.data;
      } else {
        throw Exception(result.error?.message ?? 'Failed to load dashboard');
      }
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

  /// Retry fetching data after error
  Future<void> retryFetch() async {
    await fetchDashboardData();
  }

  /// Clear error message (called when user dismisses error)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get formatted placement rate as percentage string
  String get placementRateText {
    final rate = summary.placementRate;
    if (rate == 0) return '0%';
    return '${rate.toStringAsFixed(1)}%';
  }

  /// Get formatted weekly offers text
  String get weeklyOffersText {
    final offers = summary.weeklyOffers;
    if (offers == 0) return 'No offers this week';
    return '+$offers offers this week';
  }

  /// Check if there are any upcoming drives
  bool get hasUpcomingDrives => upcomingDrives.isNotEmpty;

  /// Check if there are any department placement stats
  bool get hasDepartmentStats => departmentPlacement.isNotEmpty;

  /// Initialize ViewModel - called when screen is first created
  void initialize() {
    // Auto-fetch data when ViewModel is created
    fetchDashboardData();
  }
}
