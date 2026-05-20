import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/learning/learning_model.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';

class LearningViewModel extends ChangeNotifier {
  static const _tag = 'LearningViewModel';

  final _learning = ApiService().learning;

  List<CourseModel> courses = [];
  List<Enrollment> enrollments = [];

  /// Search query
  String searchQuery = '';

  bool isLoading = false;
  bool isLoaded = false;
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

  /// Fetch courses and enrollments in parallel. No-ops if already loaded.
  Future<void> fetchCourses() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final (coursesResult, enrollmentsResult) = await (
        _learning.getCourses(),
        _learning.getMyEnrollments(),
      ).wait;

      courses = coursesResult.isSuccess ? (coursesResult.data ?? []) : [];
      enrollments = enrollmentsResult.isSuccess
          ? (enrollmentsResult.data ?? [])
          : [];
      isLoaded = true;

      AppLogger.info(
        _tag,
        'Loaded ${courses.length} courses, ${enrollments.length} enrollments',
      );
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to fetch courses', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> fetchMyCourses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _learning.getMyEnrollments();
      enrollments = result.isSuccess ? (result.data ?? []) : [];
      AppLogger.info(_tag, 'Loaded ${enrollments.length} enrolled courses');
    } catch (e, st) {
      enrollments = [];
      AppLogger.error(_tag, 'Failed to fetch my courses', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  bool isCourseEnrolled(String courseId) =>
      enrollments.any((e) => e.course.id == courseId);

  int getProgress(String courseId) {
    final e = enrollments.firstWhere(
      (e) => e.course.id == courseId,
      orElse: () => Enrollment.empty(),
    );
    return e.progress ?? 0;
  }

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
