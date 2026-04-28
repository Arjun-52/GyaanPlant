import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/mentor_dashboard_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class MentorDashboardViewModel extends ChangeNotifier {
  final _mentor = ApiService().mentor;

  MentorDashboardModel? dashboard;
  bool isLoading = false;

  Future<void> loadDashboard() async {
    print("🔄 MENTOR VIEWMODEL: Starting loadDashboard");
    isLoading = true;
    notifyListeners();

    try {
      final result = await _mentor.getDashboard();
      if (result.isSuccess) dashboard = result.data;
    } catch (e) {
      dashboard = null;
    }
    print("🔍 MENTOR VIEWMODEL: Data updated");

    isLoading = false;
    notifyListeners();
    print("✅ MENTOR VIEWMODEL: loadDashboard completed");
  }
}
