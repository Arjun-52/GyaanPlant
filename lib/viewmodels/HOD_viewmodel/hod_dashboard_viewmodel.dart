import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/hod_dashboard_model.dart';
import 'package:gyaanplant/services/hod_services/hod_dashboard_service.dart';
import 'package:gyaanplant/services/auth_service.dart';

class HodDashboardViewModel extends ChangeNotifier {
  final HodDashboardService _service = HodDashboardService();

  HodDashboardModel? data;
  bool isLoading = false;
  String? error;

  Future<void> loadDashboard() async {
    final token = AuthService.token;
    if (token == null) throw Exception("User not logged in");

    print("TOKEN USED: $token");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      data = await _service.fetchDashboard(token);
      print("🔍 PARSED DATA: ${data?.departmentsData}");
    } catch (e) {
      error = e.toString();
      // Initialize with empty data on error to prevent UI crashes
      data = HodDashboardModel(
        totalStudents: 0,
        departments: 0,
        lmsAdoption: 0,
        naacGrade: "N/A",
        departmentsData: [],
      );
    }

    isLoading = false;
    notifyListeners();
  }

  // Safe getters for UI
  int get totalStudents => data?.totalStudents ?? 0;
  int get departments => data?.departments ?? 0;
  int get lmsAdoption => data?.lmsAdoption ?? 0;
  String get naacGrade => data?.naacGrade ?? "N/A";
  List<DeptModel> get departmentsData => data?.departmentsData ?? [];
}
