import 'package:flutter/material.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import 'package:gyaanplant/services/student_services/dashboard_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  DashboardModel? dashboard;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print("🚀 FETCH DASHBOARD CALLED");

      dashboard = await _service.getDashboard();

      print("✅ DASHBOARD OBJECT: $dashboard");
      print("XP: ${dashboard?.xp}");
      print("RANK: ${dashboard?.rank}");
      print("ENROLLMENTS: ${dashboard?.enrollments?.length}");
    } catch (e) {
      errorMessage = e.toString();
      print("❌ ERROR: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
