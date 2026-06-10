import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';
import 'package:gyaanplant/network/auth_cache.dart';
import 'package:gyaanplant/data/services/local_storage_service.dart';

class DepartmentsViewModel extends ChangeNotifier {
  final _hod = ApiService().hod;

  List<Department> departments = [];
  List<Department> _filtered = [];
  String searchQuery = '';
  bool isLoading = false;
  String? error;
  bool _disposed = false;

  /// Returns filtered list when a query is active, full list otherwise.
  List<Department> get filteredDepartments =>
      _filtered.isNotEmpty || searchQuery.isNotEmpty ? _filtered : departments;

  /// Called when user types — only updates local state, no API call.
  void updateQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  /// Called when APPLY button is pressed — runs client-side filter.
  void applyFilter() {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) {
      _filtered = [];
    } else {
      _filtered = departments.where((d) {
        final name = d.name.toLowerCase();
        final code = (d.code ?? '').toLowerCase();
        return name.contains(q) || code.contains(q);
      }).toList();
    }
    notifyListeners();
  }

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
    print("🚀 LOADING DEPARTMENTS FOR HOD");

    final token = AuthCache.token;
    print(
      "🔑 TOKEN: ${token != null ? 'Present (${token.length} chars)' : 'MISSING'}",
    );
    if (token == null) throw Exception('User not logged in');

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      print("🌐 API CALL: GET /api/v1/departments");
      final result = await _hod.getDepartments();

      print(
        "📦 API RESPONSE STATUS: ${result.isSuccess ? 'SUCCESS' : 'FAILED'}",
      );
      print("📊 RAW RESPONSE DATA: ${result.data}");

      if (result.isSuccess) {
        final departmentsList = result.data ?? [];
        print("✅ DEPARTMENTS LIST LENGTH: ${departmentsList.length}");

        if (departmentsList.isNotEmpty) {
          print("🔍 FIRST DEPARTMENT RAW DATA: ${departmentsList.first}");
        }

        departments = departmentsList;
        print("✅ DEPARTMENTS STORED: ${departments.length} departments");
        print("📊 Department Count: ${departments.length}");

        // Log each department details
        for (var dept in departments) {
          print(
            "📊 Dept: ${dept.name}, Code: ${dept.code}, HOD: ${dept.head?.name}",
          );
        }
      } else {
        print("❌ API ERROR: ${result.error?.message}");
        throw Exception(result.error?.message ?? 'Failed to load departments');
      }
    } catch (e) {
      print("💥 EXCEPTION: $e");
      error = e.toString();
    } finally {
      isLoading = false;
      print(
        "🔔 notifyListeners() called - isLoading=$isLoading, departments.length=${departments.length}",
      );
      notifyListeners();
    }
  }

  /// Debug method to check user info and API response structure
  Future<void> debugUserInfo() async {
    print("🔍 DEBUG: Checking user information for departments");

    try {
      // Check token
      final token = AuthCache.token;
      print("🔑 Token Present: ${token != null ? 'YES' : 'NO'}");

      // Check stored user data
      final userJson = await LocalStorageService.getUser();
      if (userJson != null) {
        print("👤 USER DATA: $userJson");

        // Extract college info if available
        if (userJson.containsKey('college')) {
          final college = userJson['college'];
          print("🏫 USER COLLEGE: $college");

          if (college is Map && college.containsKey('_id')) {
            final collegeId = college['_id'];
            print("🏫 COLLEGE ID: $collegeId");
            print("🎯 BACKEND FIX NEEDED:");
            print("   1. Check departments collection in MongoDB");
            print(
              "   2. Find documents where: department.college != '$collegeId'",
            );
            print(
              "   3. Update mismatched department.college field to: '$collegeId'",
            );
            print(
              "   4. OR create new departments using POST /Create Department in Clg",
            );
          }
        } else {
          print("❌ No college info found in user data");
          print("🎯 BACKEND FIX NEEDED:");
          print("   1. Check user profile for college assignment");
          print("   2. Ensure HOD user has valid collegeId in their record");
        }
      } else {
        print("❌ No user data found in local storage");
      }

      // Test API call directly
      print("🌐 Testing departments API call...");
      final result = await _hod.getDepartments();
      print("📦 API Result Success: ${result.isSuccess}");
      print("📊 API Result Data: ${result.data}");
      print("❌ API Result Error: ${result.error?.message}");

      if (result.isSuccess && result.data != null) {
        final deptCount = result.data!.length;
        print("📈 DEPARTMENTS COUNT: $deptCount");

        if (deptCount == 0) {
          print("🔍 DIAGNOSIS: Empty response confirmed");
          print("🎯 BACKEND INVESTIGATION:");
          print("   MongoDB Query: db.departments.find({})");
          print("   Check if any departments exist at all");
          print("   Check college field values in existing departments");
        }
      }
  }

  /// Create a new department
  Future<String?> createDepartment({
    required String name,
    required String code,
    required String head,
    required String location,
  }) async {
    print("🚀 ViewModel: createDepartment called");
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final userRes = await ApiService().auth.getCurrentUser();
      final collegeId = userRes.data?.college?.id;

      print("🏫 Extracted collegeId from userRes: $collegeId");

      if (collegeId == null) {
        throw Exception('No college assigned to current user');
      }

      print("🌐 API CALL: POST /api/v1/departments");
      final result = await _hod.createDepartment(
        collegeId: collegeId,
        name: name,
        code: code,
        head: head,
        location: location,
      );

      print("📦 API RESPONSE: success=${result.isSuccess}, data=${result.data}");

      if (result.isSuccess && result.data != null) {
        final message = result.data!['message']?.toString() ?? 'Department created successfully!';
        print("✅ Department created successfully: $message");
        await loadDepartments(); // Refresh list
        return message;
      } else {
        final errMsg = result.error?.message ?? 'Failed to create department';
        print("❌ Create department API failed: $errMsg");
        error = errMsg;
        return null;
      }
    } catch (e) {
      print("💥 EXCEPTION in createDepartment: $e");
      error = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
