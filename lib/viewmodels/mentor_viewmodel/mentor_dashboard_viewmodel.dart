import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/mentor_models/mentor_dashboard_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class MentorDashboardViewModel extends ChangeNotifier {
  static const _tag = 'MentorDashboardViewModel';

  final _mentor = ApiService().mentor;

  MentorDashboardModel? dashboard;
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
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _mentor.getDashboard();

      if (result.isSuccess && result.data != null) {
        dashboard = result.data;
        AppLogger.info(_tag, 'Dashboard loaded — ${dashboard?.name}');
      } else {
        error = result.error?.message ?? 'Failed to load dashboard';
        dashboard = null;
        AppLogger.error(_tag, error!);
      }
    } catch (e, st) {
      error = e.toString();
      dashboard = null;
      AppLogger.error(_tag, 'Failed to load dashboard', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }
}
