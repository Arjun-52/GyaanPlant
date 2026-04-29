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
    // 1. Verify API request is being triggered
    print("🚀 CALLING COURSES API - fetchCourses() started");

    // 2. Verify token is attached
    final token = AuthCache.token;
    if (token == null) {
      print("❌ TOKEN MISSING: No authentication token found");
      errorMessage = 'Please login to access courses';
      notifyListeners();
      return;
    }

    print("🔑 TOKEN: ${token.substring(0, 20)}...");
    print("🔑 TOKEN LENGTH: ${token.length} characters");

    // 3. Log API request details
    print("🌐 URL: /api/v1/learning");
    print("🌐 METHOD: GET");
    print("🌐 HEADERS: Authorization: Bearer ${token.substring(0, 20)}...");

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print("📡 MAKING API CALL...");
      final result = await _learning.getCourses();

      // 4. Log API response
      print("📦 STATUS: ${result.isSuccess ? 'SUCCESS' : 'FAILED'}");
      print("📦 RESPONSE: ${result.data}");
      print("📦 ERROR: ${result.error}");

      if (result.isSuccess) {
        // 5. Validate response structure
        final data = result.data;
        print("📊 RESPONSE TYPE: ${data.runtimeType}");
        print("📊 RESPONSE DATA: $data");

        if (data != null && data is List) {
          print("📊 COURSES COUNT: ${data.length}");
          print(
            "📊 FIRST COURSE: ${data.isNotEmpty ? data.first : 'NO COURSES'}",
          );
        } else {
          print("⚠️ RESPONSE IS NOT A LIST: $data");
        }

        // 6. Verify ViewModel mapping
        courses = data ?? [];
        print("✅ COURSES STORED: ${courses.length} items");
        print("✅ COURSES TYPE: ${courses.runtimeType}");

        if (courses.isNotEmpty) {
          print("✅ FIRST COURSE: ${courses.first}");
        }
      } else {
        errorMessage = result.error?.message ?? 'Failed to fetch courses';
        courses = [];
        print("❌ COURSES FETCH FAILED: $errorMessage");
        print("❌ ERROR DETAILS: ${result.error}");
      }
    } catch (e, stackTrace) {
      errorMessage = e.toString();
      courses = [];
      print("💥 COURSES FETCH ERROR: $e");
      print("💥 STACK TRACE: $stackTrace");
    } finally {
      isLoading = false;
      // 7. Verify notifyListeners() timing
      print(
        "🔄 notifyListeners() called - isLoading: $isLoading, courses: ${courses.length}",
      );
      notifyListeners();
    }
  }
}
