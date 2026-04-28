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
    final token = AuthService.token;
    if (token == null) throw Exception("User not logged in");

    print("TOKEN USED: $token");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _hod.getDashboard();
      if (result.isSuccess) {
        data = result.data;
      } else {
        throw Exception(result.error?.message ?? 'Failed to load dashboard');
      }
      print("🔍 PARSED DATA: ${data?.departmentsData}");

      // TEMPORARY: Add mock data if API returns empty departments
      if (data?.departmentsData.isEmpty ?? true) {
        print("🧪 ADDING MOCK DEPARTMENT DATA FOR TESTING");
        data = HodDashboardModel(
          totalStudents: data?.totalStudents ?? 1250,
          departments: data?.departments ?? 4,
          lmsAdoption: data?.lmsAdoption ?? 75,
          naacGrade: data?.naacGrade ?? "A",
          departmentsData: [
            DeptModel(name: "CSE", value: 85.0),
            DeptModel(name: "IT", value: 72.5),
            DeptModel(name: "ECE", value: 68.0),
            DeptModel(name: "MECH", value: 45.5),
          ],
        );
        print(
          "🧪 MOCK DATA ADDED: ${data?.departmentsData.length} departments",
        );
      }
    } catch (e) {
      print("🧪 API ERROR: $e");
      error = _getErrorMessage(e.toString());

      // Don't add mock data on error - let the UI show the error message
      // This prevents crashes and shows user-friendly error messages
    }

    isLoading = false;
    notifyListeners();
  }

  // Convert technical error messages to user-friendly messages
  String _getErrorMessage(String technicalError) {
    print("🔍 TECHNICAL ERROR: $technicalError");

    // Check for specific error patterns and return user-friendly messages
    if (technicalError.toLowerCase().contains("no department assigned")) {
      return "No department assigned. Contact admin.";
    }

    if (technicalError.toLowerCase().contains("invalid token") ||
        technicalError.toLowerCase().contains("unauthorized")) {
      return "Session expired. Please login again.";
    }

    if (technicalError.toLowerCase().contains("forbidden") ||
        technicalError.toLowerCase().contains("access denied")) {
      return "Access denied. You don't have HOD permissions.";
    }

    if (technicalError.toLowerCase().contains("network") ||
        technicalError.toLowerCase().contains("connection")) {
      return "Network error. Please check your internet connection.";
    }

    if (technicalError.toLowerCase().contains("server") ||
        technicalError.toLowerCase().contains("500")) {
      return "Server error. Please try again later.";
    }

    if (technicalError.toLowerCase().contains("404")) {
      return "Service not found. Contact support.";
    }

    // Default fallback for unknown errors
    return "Unable to load dashboard. Please try again.";
  }

  // Safe getters for UI
  int get totalStudents => data?.totalStudents ?? 0;
  int get departments => data?.departments ?? 0;
  int get lmsAdoption => data?.lmsAdoption ?? 0;
  String get naacGrade => data?.naacGrade ?? "N/A";
  List<DeptModel> get departmentsData => data?.departmentsData ?? [];
}
