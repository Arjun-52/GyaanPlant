import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/HOD_models/analytics_model.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/hod_dashboard_viewmodel.dart';

class AnalyticsViewModel extends ChangeNotifier {
  static const _tag = 'AnalyticsViewModel';

  final HodDashboardViewModel dashboard;

  AnalyticsModel? analyticsData;
  bool _disposed = false;

  AnalyticsViewModel(this.dashboard);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  // Getters
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

  void generateAnalytics() {
    final d = dashboard.data;
    if (d == null) {
      AppLogger.warning(_tag, 'Dashboard data not yet loaded');
      return;
    }

    final students = d.totalStudents;
    final completion = d.lmsAdoption;

    analyticsData = AnalyticsModel(
      monthlyActive: [
        (students * 0.5).toInt(),
        (students * 0.6).toInt(),
        (students * 0.7).toInt(),
        (students * 0.8).toInt(),
        (students * 0.9).toInt(),
        students,
      ],
      placementRates: [
        (completion - 10).clamp(0, 100),
        (completion - 5).clamp(0, 100),
        completion.clamp(0, 100),
        (completion + 5).clamp(0, 100),
      ],
      activeStudents: students,
      avgHours: 0.0,
      readinessScore: completion,
      certificates: 0,
      departments: [],
      readiness: [],
      placementStats: {},
      topPerformers: [],
      lowPerformers: [],
    );

    AppLogger.info(_tag, 'Analytics generated — $students students');
    notifyListeners();
  }
}
