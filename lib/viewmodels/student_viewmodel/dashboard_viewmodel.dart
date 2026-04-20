import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import 'package:gyaanplant/services/student_services/dashboard_service.dart';

class DashboardViewModel extends ChangeNotifier {
  static const _tag = 'DashboardViewModel';
  final DashboardService _service = DashboardService();

  DashboardModel? dashboard;
  bool isLoading = false;
  bool isLoaded = false;
  String? errorMessage;
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

  Future<void> fetchDashboard() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      dashboard = await _service.getDashboard();
      isLoaded = true;
      AppLogger.info(_tag, 'Dashboard loaded');
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to load dashboard', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
