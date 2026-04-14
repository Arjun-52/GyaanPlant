import 'package:flutter/material.dart';
import 'package:gyaanplant/models/dashboard_model.dart';
import 'package:gyaanplant/services/dashboard_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  DashboardModel? dashboard;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchDashboard() async {
    print('🔄 DashboardViewModel: Starting fetchDashboard');
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      dashboard = await _service.getDashboard();
      print('✅ DashboardViewModel: Successfully fetched dashboard data');
      print(
        '📊 Dashboard Data - XP: ${dashboard?.xp}, Rank: ${dashboard?.rank}, Progress: ${dashboard?.xpProgress}',
      );
      print("Enrollments: ${dashboard?.enrollments}");
    } catch (e) {
      print('❌ DashboardViewModel: Failed to fetch dashboard - $e');
      errorMessage = 'Failed to load dashboard: $e';
      dashboard = null;
    }

    isLoading = false;
    notifyListeners();
    print('🏁 DashboardViewModel: fetchDashboard completed');
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
