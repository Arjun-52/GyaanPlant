import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';

import 'package:gyaanplant/models/learning/learning_model.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import 'package:gyaanplant/network/auth_cache.dart';

class LearningViewModel extends ChangeNotifier {
  final _learning = ApiService().learning;

  List<CourseModel> courses = [];
  List<Enrollment> enrollments = [];
  bool isLoading = false;
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

  Future<void> fetchCourses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _learning.getCourses();

      if (result.isSuccess) {
        courses = result.data ?? [];
      } else {
        errorMessage = result.error?.message ?? 'Failed to fetch courses';
        courses = [];
      }
    } catch (e) {
      errorMessage = e.toString();
      courses = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEnrollments() async {
    // Check if token is available before making API call
    final token = AuthCache.token;
    if (token == null) {
      errorMessage = 'Please login to access enrollments';
      notifyListeners();
      return;
    }

    print("🔑 FETCHING ENROLLMENTS WITH TOKEN: ${token.substring(0, 20)}...");

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _learning.getMyEnrollments();

      if (result.isSuccess) {
        enrollments = result.data ?? [];
        print("✅ ENROLLMENTS FETCHED: ${enrollments.length} items");
      } else {
        errorMessage = result.error?.message ?? 'Failed to fetch enrollments';
        enrollments = [];
        print("❌ ENROLLMENTS FETCH FAILED: $errorMessage");
      }
    } catch (e) {
      errorMessage = e.toString();
      enrollments = [];
      print("💥 ENROLLMENTS FETCH ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
