import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';
import 'package:gyaanplant/models/HOD_models/employee_model.dart';
import 'package:gyaanplant/repositories/hod_repository.dart';
import 'package:gyaanplant/network/api_response.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class DepartmentDetailsViewModel extends ChangeNotifier {
  final HodRepository _repo = ApiService().hod;

  bool isLoading = false;
  String? error;
  Department? department;
  // Additional fields from department API
  int? totalEmployees;
  List<Employee> faculty = [];
  String? city;

  Future<void> loadDepartment(String departmentId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await _repo.getDepartmentDetails(departmentId);
      if (response.isSuccess) {
        // The API returns a Department model directly.
        // Previously the code attempted to cast response.data to Map and parse extra fields,
        // which caused a type error because response.data is a Department instance.
        final deptData = response.data;
        if (deptData != null) {
          department = deptData;
        } else {
          error = 'Department data is null';
        }
        // Populate additional fields if needed. Currently the repository only returns core fields.
        totalEmployees = null;
        city = null;
        faculty = [];
      } else {
        error = response.error?.message ?? 'Failed to load department';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
