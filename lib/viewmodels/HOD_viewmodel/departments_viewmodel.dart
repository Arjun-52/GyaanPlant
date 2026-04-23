import 'package:flutter/material.dart';
import 'package:gyaanplant/services/hod_services/dept_service.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';

class DepartmentsViewModel extends ChangeNotifier {
  final DeptService _service = DeptService();

  List<Department> departments = [];
  bool isLoading = false;
  String? error;

  Future<void> loadDepartments(String token) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      departments = await _service.fetchDepts(token);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
