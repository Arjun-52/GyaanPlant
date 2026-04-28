import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';
import 'package:gyaanplant/services/auth_service.dart';

class DepartmentsViewModel extends ChangeNotifier {
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
    final token = AuthService.token;
    if (token == null) throw Exception('User not logged in');

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _hod.getDepartments();
      if (result.isSuccess) {
        departments = result.data ?? [];
      } else {
        throw Exception(result.error?.message ?? 'Failed to load departments');
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
