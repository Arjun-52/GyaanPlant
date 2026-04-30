import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/analytics_model.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/hod_dashboard_viewmodel.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final HodDashboardViewModel dashboard;

  AnalyticsModel? analyticsData;

  AnalyticsViewModel(this.dashboard);

  // ===== GETTERS =====
  List<int> get monthlyActive => analyticsData?.monthlyActive ?? [];
  List<int> get placementRates => analyticsData?.placementRates ?? [];
  int get activeStudents => analyticsData?.activeStudents ?? 0;
  double get avgHours => analyticsData?.avgHours ?? 0.0;
  int get readinessScore => analyticsData?.readinessScore ?? 0;
  int get certificates => analyticsData?.certificates ?? 0;

  List<dynamic> get departments => analyticsData?.departments ?? [];
  List<dynamic> get readiness => analyticsData?.readiness ?? [];
  Map<String, dynamic> get placementStats =>
      analyticsData?.placementStats ?? {};
  List<dynamic> get topPerformers => analyticsData?.topPerformers ?? [];
  List<dynamic> get lowPerformers => analyticsData?.lowPerformers ?? [];

  // ===== GENERATE DATA FROM DASHBOARD =====
  void generateAnalytics() {
    final d = dashboard.data;

    if (d == null) {
      print("❌ Dashboard data is null");
      return;
    }

    print("🔍 DASHBOARD DATA: $d");

    final students = d.totalStudents;
    final completion = d.lmsAdoption;

    analyticsData = AnalyticsModel(
      // Fake monthly growth based on students
      monthlyActive: [
        (students * 0.5).toInt(),
        (students * 0.6).toInt(),
        (students * 0.7).toInt(),
        (students * 0.8).toInt(),
        (students * 0.9).toInt(),
        students,
      ],

      // Fake yearly placement trend
      placementRates: [
        (completion - 10).clamp(0, 100),
        (completion - 5).clamp(0, 100),
        completion.clamp(0, 100),
        (completion + 5).clamp(0, 100),
      ],

      activeStudents: students,
      avgHours: 12.4,
      readinessScore: completion,
      certificates: students * 2,

      departments: [],
      readiness: [],
      placementStats: {},
      topPerformers: [],
      lowPerformers: [],
    );

    print("✅ ANALYTICS DATA GENERATED:");
    print("   - Monthly Active: ${analyticsData?.monthlyActive}");
    print("   - Placement Rates: ${analyticsData?.placementRates}");
    print("   - Active Students: ${analyticsData?.activeStudents}");
    print("   - Readiness Score: ${analyticsData?.readinessScore}");

    notifyListeners();
  }
}
