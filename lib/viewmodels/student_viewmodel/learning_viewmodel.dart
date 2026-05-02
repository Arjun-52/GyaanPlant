import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/learning/learning_model.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import 'package:gyaanplant/network/auth_cache.dart';

class LearningViewModel extends ChangeNotifier {
  final _learning = ApiService().learning;

  /// All available courses
  List<CourseModel> courses = [];

  /// Enrollments (contains course + progress)
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

  /// Fetch everything (courses + enrollments)
  Future<void> fetchCourses() async {
    print("🚀 FETCH COURSES STARTED");

    final token = AuthCache.token;
    if (token == null) {
      errorMessage = 'Please login';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final coursesResult = await _learning.getCourses();
      final enrollmentsResult = await _learning.getMyEnrollments();

      /// ALL COURSES
      if (coursesResult.isSuccess) {
        courses = coursesResult.data ?? [];
        print("✅ COURSES: ${courses.length}");
      } else {
        courses = [];
      }

      /// ENROLLMENTS
      if (enrollmentsResult.isSuccess) {
        enrollments = enrollmentsResult.data ?? [];
        print("✅ ENROLLMENTS: ${enrollments.length}");
      } else {
        enrollments = [];
      }
    } catch (e) {
      errorMessage = e.toString();
      print("💥 ERROR: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Only enrolled courses (for My Courses screen)
  Future<void> fetchMyCourses() async {
    print("🚀 FETCH MY COURSES");

    isLoading = true;
    notifyListeners();

    try {
      final result = await _learning.getMyEnrollments();

      if (result.isSuccess) {
        enrollments = result.data ?? [];
        print("📚 MY COURSES: ${enrollments.length}");
      } else {
        enrollments = [];
      }
    } catch (e) {
      print("💥 ERROR: $e");
      enrollments = [];
    }

    isLoading = false;
    notifyListeners();
  }

  /// Check enrollment
  bool isCourseEnrolled(String courseId) {
    return enrollments.any((e) => e.course.id == courseId);
  }

  /// Get progress
  int getProgress(String courseId) {
    final e = enrollments.firstWhere(
      (e) => e.course.id == courseId,
      orElse: () => Enrollment.empty(),
    );
    return e.progress ?? 0;
  }

  /// Get enrolled courses list (for UI)
  List<Enrollment> get myCourses => enrollments;
}
