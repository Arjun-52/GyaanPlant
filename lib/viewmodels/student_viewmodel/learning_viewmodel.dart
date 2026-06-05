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

  /// Search query
  String searchQuery = '';

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
    print("🚀 [LearningViewModel] FETCH COURSES STARTED. Setting isLoading = true");
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final token = AuthCache.token;
    if (token == null) {
      print("⚠️ [LearningViewModel] AuthCache.token is null! Proceeding anyway for the temporary test flow.");
    }

    try {
      print("🚀 [LearningViewModel] Calling _learning.getCourses()...");
      final coursesResult = await _learning.getCourses();
      print("🚀 [LearningViewModel] Courses response received: isSuccess=${coursesResult.isSuccess}");

      print("🚀 [LearningViewModel] Calling _learning.getMyEnrollments()...");
      final enrollmentsResult = await _learning.getMyEnrollments();
      print("🚀 [LearningViewModel] Enrollments response received: isSuccess=${enrollmentsResult.isSuccess}");

      /// ALL COURSES
      if (coursesResult.isSuccess) {
        courses = coursesResult.data ?? [];
        print("✅ [LearningViewModel] COURSES LOADED: ${courses.length}");
      } else {
        courses = [];
        print("❌ [LearningViewModel] Failed to load courses: ${coursesResult.error?.message}");
      }

      /// ENROLLMENTS
      if (enrollmentsResult.isSuccess) {
        enrollments = enrollmentsResult.data ?? [];
        print("✅ [LearningViewModel] ENROLLMENTS LOADED: ${enrollments.length}");
      } else {
        enrollments = [];
        print("❌ [LearningViewModel] Failed to load enrollments: ${enrollmentsResult.error?.message}");
      }
    } catch (e) {
      errorMessage = e.toString();
      print("💥 [LearningViewModel] ERROR in fetchCourses: $e");
    } finally {
      print("🚀 [LearningViewModel] fetchCourses completed. Setting isLoading = false");
      isLoading = false;
      if (!_disposed) {
        notifyListeners();
        print("🚀 [LearningViewModel] Listeners notified.");
      }
    }
  }

  /// Only enrolled courses (for My Courses screen)
  Future<void> fetchMyCourses() async {
    print("🚀 [LearningViewModel] FETCH MY COURSES. Setting isLoading = true");

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print("🚀 [LearningViewModel] Calling _learning.getMyEnrollments()...");
      final result = await _learning.getMyEnrollments();
      print("🚀 [LearningViewModel] Enrollments response: isSuccess=${result.isSuccess}");

      if (result.isSuccess) {
        enrollments = result.data ?? [];
        print("📚 [LearningViewModel] MY COURSES: ${enrollments.length}");
      } else {
        enrollments = [];
        print("❌ [LearningViewModel] Failed to load my courses: ${result.error?.message}");
      }
    } catch (e) {
      errorMessage = e.toString();
      print("💥 [LearningViewModel] ERROR in fetchMyCourses: $e");
      enrollments = [];
    } finally {
      print("🚀 [LearningViewModel] fetchMyCourses completed. Setting isLoading = false");
      isLoading = false;
      if (!_disposed) {
        notifyListeners();
        print("🚀 [LearningViewModel] Listeners notified.");
      }
    }
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

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  /// Get filtered courses based on search
  List<CourseModel> get filteredCourses {
    if (searchQuery.isEmpty) {
      return courses;
    }

    return courses.where((course) {
      final query = searchQuery.toLowerCase();
      return course.title.toLowerCase().contains(query) ||
          (course.description?.toLowerCase().contains(query) ?? false) ||
          (course.category?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Get available courses (not enrolled) and filtered
  List<CourseModel> get availableFilteredCourses {
    return filteredCourses
        .where((course) => !isCourseEnrolled(course.id))
        .toList();
  }
}
