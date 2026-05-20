import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/data/services/api_service.dart';
<<<<<<< Updated upstream
=======
import 'package:gyaanplant/network/auth_cache.dart';
import 'dart:math' as math;
>>>>>>> Stashed changes

class TpoDashboardViewModel extends ChangeNotifier {
  static const _tag = 'TpoDashboardViewModel';

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  bool _disposed = false;

  int activeDrives = 0;
  int closingSoon = 0;
  int totalStudents = 0;
  double placementRate = 0.0;
  int offersExtended = 0;
  int weeklyOffers = 0;
  int studentsPlaced = 0;
  List<Map<String, dynamic>> drives = [];
  String collegeName = '';

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get hasData =>
      totalStudents > 0 ||
      activeDrives > 0 ||
      weeklyOffers > 0 ||
      studentsPlaced > 0 ||
      drives.isNotEmpty;
  bool get hasError => _errorMessage != null;
  bool get hasUpcomingDrives => drives.isNotEmpty;
  String get placementRateText =>
      placementRate == 0 ? '0%' : '${placementRate.toStringAsFixed(1)}%';
  String get weeklyOffersText =>
      weeklyOffers == 0 ? 'No offers this week' : '+$weeklyOffers offers this week';

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> fetchDashboardData() async {
<<<<<<< Updated upstream
=======
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

>>>>>>> Stashed changes
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService().tpo.getDashboard();

      if (result.isSuccess && result.data != null) {
        _parseDashboard(result.data as Map<String, dynamic>);
        AppLogger.info(_tag, 'Dashboard loaded — $activeDrives active drives');
      } else {
        _errorMessage = result.error?.message ?? 'Failed to load dashboard';
        AppLogger.error(_tag, _errorMessage!);
      }
    } catch (e, st) {
      _errorMessage = 'Parsing error: ${e.toString()}';
      _resetData();
      AppLogger.error(_tag, 'Failed to load dashboard', e, st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboardData() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      await fetchDashboardData();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> retryFetch() async {
    _resetData();
    await fetchDashboardData();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void initialize() {
    fetchDashboardData();
    fetchCollegeName();
  }

  Future<void> fetchCollegeName() async {
    try {
      final userRes = await ApiService().auth.getCurrentUser();
      collegeName = userRes.data?.college?.toString() ?? 'No College Assigned';
    } catch (e) {
      collegeName = 'Error loading college';
      AppLogger.error(_tag, 'Failed to fetch college name', e);
    }
    notifyListeners();
  }

  void _parseDashboard(Map<String, dynamic> response) {
    Map<String, dynamic> data = {};

    if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
      data = response['data'] as Map<String, dynamic>;
    } else {
      data = response;
    }

    final summary = data['summary'] is Map<String, dynamic>
        ? data['summary'] as Map<String, dynamic>
        : <String, dynamic>{};

    final upcomingDrives =
        data['upcomingDrives'] is List ? data['upcomingDrives'] as List : [];

    activeDrives = summary['activeDrives'] is int ? summary['activeDrives'] as int : 0;
    closingSoon = summary['closingSoon'] is int ? summary['closingSoon'] as int : 0;
    totalStudents = summary['totalStudents'] is int ? summary['totalStudents'] as int : 0;
    placementRate = summary['placementRate'] is num
        ? (summary['placementRate'] as num).toDouble()
        : 0.0;
    offersExtended = summary['offersExtended'] is int ? summary['offersExtended'] as int : 0;
    weeklyOffers = summary['weeklyOffers'] is int ? summary['weeklyOffers'] as int : 0;
    studentsPlaced = summary['studentsPlaced'] is int ? summary['studentsPlaced'] as int : 0;

    drives = upcomingDrives
        .where((e) => e is Map<String, dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  void _resetData() {
    activeDrives = 0;
    closingSoon = 0;
    totalStudents = 0;
    placementRate = 0.0;
    offersExtended = 0;
    weeklyOffers = 0;
    studentsPlaced = 0;
    drives = [];
  }
}
