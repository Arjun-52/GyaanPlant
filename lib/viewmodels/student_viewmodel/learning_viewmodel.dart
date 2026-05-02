import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/learning/learning_model.dart';
import 'package:gyaanplant/network/auth_cache.dart';

class LearningViewModel extends ChangeNotifier {
  final _learning = ApiService().learning;

  List<CourseModel> courses = [];
  List<CourseModel> enrolledCourses = [];
  List activeCourses = [];

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
    print("🚀 FETCH COURSES STARTED");

    final token = AuthCache.token;
    if (token == null) {
      errorMessage = 'Please login to access courses';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Fetch all available courses
      final coursesResult = await _learning.getCourses();

      // Fetch enrolled courses
      final enrolledResult = await _learning.getMyEnrolledCourses();

      print("📦 RAW COURSES RESPONSE: ${coursesResult.data}");
      print("📦 RAW ENROLLED RESPONSE: ${enrolledResult.data}");

      if (coursesResult.isSuccess) {
        // Repository already returns List<CourseModel>, no parsing needed
        courses = coursesResult.data ?? [];

        print("📦 COURSES DATA TYPE: ${coursesResult.data.runtimeType}");
        if (courses.isNotEmpty) {
          print("📦 FIRST COURSE TYPE: ${courses.first.runtimeType}");
        }
        print("✅ TOTAL COURSES: ${courses.length}");
        print("✅ COURSES: ${courses.map((c) => c.title).toList()}");
      } else {
        courses = [];
        errorMessage =
            coursesResult.error?.message ?? 'Failed to fetch courses';
        print("⚠️ COURSES API ERROR: ${errorMessage}");
      }

      if (enrolledResult.isSuccess) {
        enrolledCourses = enrolledResult.data ?? [];

        final enrolledIds = enrolledCourses.map((e) => e.id).toSet();
        print("✅ ENROLLED COURSES: ${enrolledCourses.length}");
        print("✅ ENROLLED IDS: $enrolledIds");
        print(
          "✅ ENROLLED TITLES: ${enrolledCourses.map((c) => c.title).toList()}",
        );
      } else {
        enrolledCourses = [];
        print("⚠️ ENROLLED API ERROR: ${enrolledResult.error?.message}");
      }
    } catch (e) {
      errorMessage = e.toString();
      courses = [];
      enrolledCourses = [];
      print("💥 ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
