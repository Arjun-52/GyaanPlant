import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/HOD_models/hod_dashboard_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/network/auth_cache.dart';

class HodDashboardViewModel extends ChangeNotifier {
  static const _tag = 'HodDashboardViewModel';

  final _hod = ApiService().hod;

  HodDashboardModel? data;
  bool isLoading = false;
  String? error;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> loadDashboard() async {
<<<<<<< Updated upstream
    if (AuthCache.token == null) {
      error = 'Not logged in';
      notifyListeners();
      return;
    }
=======
    print("🚀 LOADING HOD DASHBOARD");

    final token = AuthCache.token;
    print(
      "🔑 TOKEN: ${token != null ? 'Present (${token.length} chars)' : 'MISSING'}",
    );
    if (token == null) throw Exception("User not logged in");
>>>>>>> Stashed changes

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _hod.getDashboard();

      if (result.isSuccess) {
        data = result.data;
        AppLogger.info(_tag, 'Dashboard loaded — ${data?.totalStudents} students');
      } else {
        error = result.error?.message ?? 'Failed to load dashboard';
        AppLogger.error(_tag, error!);
      }
    } catch (e, st) {
      error = e.toString();
      AppLogger.error(_tag, 'Failed to load dashboard', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Safe getters for UI
  int get totalStudents => data?.totalStudents ?? 0;
  int get departments => data?.departments ?? 0;
  int get lmsAdoption => data?.lmsAdoption ?? 0;
  String get naacGrade => data?.naacGrade ?? 'N/A';
  List<DeptModel> get departmentsData => data?.departmentsData ?? [];
}
