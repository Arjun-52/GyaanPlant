import 'package:flutter/material.dart';
import 'package:gyaanplant/services/hod_services/dept_service.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';
import 'package:gyaanplant/services/auth_service.dart';

class DepartmentsViewModel extends ChangeNotifier {
  final DeptService _service = DeptService();

  List<Department> departments = [];
  bool isLoading = false;
  String? error;

  Future<void> loadDepartments() async {
    final token = AuthService.token;
    if (token == null) throw Exception("User not logged in");

    print("TOKEN USED: $token");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      print("🔄 VIEWMODEL: Calling fetchDepts...");
      departments = await _service.fetchDepts(token);
      print("🔄 VIEWMODEL: Received ${departments.length} departments");
      print("🔄 VIEWMODEL: Final departments list: $departments");
    } catch (e) {
      print("❌ VIEWMODEL ERROR: $e");
      error = e.toString();
    }

    isLoading = false;
    print("🔄 VIEWMODEL: Loading finished, notifying listeners");
    notifyListeners();
  }
}
