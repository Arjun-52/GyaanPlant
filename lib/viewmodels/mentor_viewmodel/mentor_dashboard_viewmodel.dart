import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/mentor_dashboard_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class MentorDashboardViewModel extends ChangeNotifier {
  final _mentor = ApiService().mentor;

  MentorDashboardModel? dashboard;
  bool isLoading = false;
  String? error;

  Future<void> loadDashboard() async {
    print("🔄 MENTOR VIEWMODEL: Starting loadDashboard");
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      print("🌐 MENTOR API: Calling getDashboard()");
      final result = await _mentor.getDashboard();
      print("📦 MENTOR API RESPONSE: isSuccess=${result.isSuccess}");

      if (result.isSuccess && result.data != null) {
        dashboard = result.data;
        print("✅ MENTOR DASHBOARD LOADED:");
        print("   - Name: ${dashboard?.name}");
        print("   - Role: ${dashboard?.role}");
        print("   - Sessions: ${dashboard?.sessionsDone}");
        print("   - Earnings: ${dashboard?.earnings}");
        print("   - Rating: ${dashboard?.rating}");
      } else {
        print("❌ MENTOR API ERROR: ${result.error?.message}");
        error = result.error?.message ?? 'Failed to load dashboard';
        dashboard = null;
      }
    } catch (e) {
      print("� MENTOR VIEWMODEL EXCEPTION: $e");
      error = e.toString();
      dashboard = null;
    }

    isLoading = false;
    notifyListeners();
    print(
      "✅ MENTOR VIEWMODEL: loadDashboard completed - hasData=${dashboard != null}",
    );
  }
}
