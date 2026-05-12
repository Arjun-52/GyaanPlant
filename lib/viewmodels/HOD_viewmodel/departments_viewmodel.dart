import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';
import 'package:gyaanplant/network/auth_cache.dart';

class DepartmentsViewModel extends ChangeNotifier {
  static const _tag = 'DepartmentsViewModel';

  final _hod = ApiService().hod;

  List<Department> departments = [];
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

  Future<void> loadDepartments() async {
    if (AuthCache.token == null) {
      error = 'Not logged in';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _hod.getDepartments();

      if (result.isSuccess) {
        departments = result.data ?? [];
        AppLogger.info(_tag, 'Loaded ${departments.length} departments');
      } else {
        error = result.error?.message ?? 'Failed to load departments';
        AppLogger.error(_tag, error!);
      }
    } catch (e, st) {
      error = e.toString();
      AppLogger.error(_tag, 'Failed to load departments', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
