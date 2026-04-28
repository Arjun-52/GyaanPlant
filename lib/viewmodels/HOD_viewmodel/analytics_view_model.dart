import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/HOD_models/analytics_model.dart';
import 'package:gyaanplant/services/auth_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final _hod = ApiService().hod;

  AnalyticsModel? analyticsData;
  bool isLoading = false;
  String? error;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  List<int> get monthlyActive => analyticsData?.monthlyActive ?? [];
  List<int> get placementRates => analyticsData?.placementRates ?? [];
  int get activeStudents => analyticsData?.activeStudents ?? 0;
  double get avgHours => analyticsData?.avgHours ?? 0.0;
  int get readinessScore => analyticsData?.readinessScore ?? 0;
  int get certificates => analyticsData?.certificates ?? 0;

  List<dynamic> get departments => analyticsData?.departments ?? [];
  List<dynamic> get readiness => analyticsData?.readiness ?? [];
  Map<String, dynamic> get placementStats => analyticsData?.placementStats ?? {};
  List<dynamic> get topPerformers => analyticsData?.topPerformers ?? [];
  List<dynamic> get lowPerformers => analyticsData?.lowPerformers ?? [];

  Future<void> fetchAnalytics() async {
    final token = AuthService.token;
    if (token == null) throw Exception('User not logged in');

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _hod.getAnalytics();
      if (result.isSuccess) {
        analyticsData = result.data;
      } else {
        throw Exception(result.error?.message ?? 'Failed to load analytics');
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
