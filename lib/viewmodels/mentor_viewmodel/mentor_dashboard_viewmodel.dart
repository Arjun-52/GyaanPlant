import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/mentor_dashboard_model.dart';
import 'package:gyaanplant/services/mentor_services/mentor_dashboard_service.dart';

class MentorDashboardViewModel extends ChangeNotifier {
  final MentorDashboardService _service = MentorDashboardService();

  MentorDashboardModel? dashboard;
  bool isLoading = false;

  Future<void> loadDashboard() async {
    print("🔄 MENTOR VIEWMODEL: Starting loadDashboard");
    isLoading = true;
    notifyListeners();

    dashboard = await _service.fetchDashboard();
    print("🔍 MENTOR VIEWMODEL: Service returned: $dashboard");

    isLoading = false;
    notifyListeners();
    print("✅ MENTOR VIEWMODEL: loadDashboard completed");
  }
}
