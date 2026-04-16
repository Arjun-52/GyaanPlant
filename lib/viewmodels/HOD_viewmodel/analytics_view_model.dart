import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/analytics_model.dart';

class AnalyticsViewModel extends ChangeNotifier {
  AnalyticsModel? analytics;
  bool isLoading = false;

  Future<void> fetchAnalytics() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1)); // simulate API

    // Mock data (replace with API later)
    analytics = AnalyticsModel(
      activeStudents: 2076,
      growthPercent: 8,
      avgHours: 12.4,
      readinessScore: 67,
      certificates: 1240,
    );

    isLoading = false;
    notifyListeners();
  }
}
