import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import '../../data/services/api_service.dart';

class DashboardViewModel extends ChangeNotifier {
  static const _tag = 'DashboardViewModel';

  final _student = ApiService().student;

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
      final result = await _student.getDashboard();

      if (result.isSuccess) {
        final data = result.data!;
        dashboard = DashboardModel(
          xp: data.xp,
          rank: data.rank,
          xpProgress: data.xpProgress,
          enrollments: const [],
          drives: const [],
          student: {
            'name': data.student.user?.name,
            'email': data.student.user?.email,
          },
        );
        isLoaded = true;
        AppLogger.info(_tag, 'Dashboard loaded');
      } else {
        errorMessage = result.error?.message ?? 'Failed to load dashboard';
        AppLogger.error(_tag, errorMessage!);
      }
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to load dashboard', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }
}
