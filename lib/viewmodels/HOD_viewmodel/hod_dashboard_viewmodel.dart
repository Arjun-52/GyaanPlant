import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/hod_dashboard_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/services/auth_service.dart';

class HodDashboardViewModel extends ChangeNotifier {
  final _hod = ApiService().hod;

  HodDashboardModel? data;
  bool isLoading = false;
  String? error;

  Future<void> loadDashboard() async {
    print("🚀 LOADING HOD DASHBOARD");

    final token = AuthService.token;
    print(
      "🔑 TOKEN: ${token != null ? 'Present (${token.length} chars)' : 'MISSING'}",
    );
    if (token == null) throw Exception("User not logged in");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      print("🌐 API CALL: GET /api/v1/dashboard/hod");
      final result = await _hod.getDashboard();
      print("📦 RESPONSE STATUS: ${result.isSuccess ? 'SUCCESS' : 'FAILED'}");

      if (result.isSuccess) {
        data = result.data;
        print("✅ HOD DASHBOARD DATA LOADED:");
        print("   - Total Students: ${data?.totalStudents}");
        print("   - Departments: ${data?.departments}");
        print("   - LMS Adoption: ${data?.lmsAdoption}");
        print("🔍 PARSED DATA: ${data?.departmentsData}");
      } else {
        print("❌ API ERROR: ${result.error?.message}");
        throw Exception(result.error?.message ?? 'Failed to load dashboard');
      }
    } catch (e) {
      print("💥 EXCEPTION: $e");
      error = e.toString();
    } finally {
      isLoading = false;
      print(
        "� HOD Dashboard notifyListeners() called - isLoading=$isLoading, hasData=${data != null}",
      );
      notifyListeners();
    }
  }

  // Safe getters for UI
  int get totalStudents => data?.totalStudents ?? 0;
  int get departments => data?.departments ?? 0;
  int get lmsAdoption => data?.lmsAdoption ?? 0;
  String get naacGrade => data?.naacGrade ?? "N/A";
  List<DeptModel> get departmentsData => data?.departmentsData ?? [];
}
