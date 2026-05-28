import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/learning/course_progress_model.dart';
import 'package:gyaanplant/models/learning/learning_model.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import 'package:gyaanplant/network/auth_cache.dart';

/// Result type for progress update operations.
class ProgressUpdateResult {
  final bool success;
  final String message;
  final CourseProgressModel? progress;
  final bool isRetryRestricted;

  const ProgressUpdateResult({
    required this.success,
    required this.message,
    this.progress,
    this.isRetryRestricted = false,
  });
}

class LearningViewModel extends ChangeNotifier {
  static const _tag = 'LearningViewModel';

  final _learning = ApiService().learning;

  /// All available courses
  List<CourseModel> courses = [];

  /// Enrollments (contains course + progress)
  List<Enrollment> enrollments = [];

  /// Search query
  String searchQuery = '';

  bool isLoading = false;
  String? errorMessage;

  /// Guard against duplicate concurrent progress PUT calls.
  bool _isProgressUpdating = false;

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
    AppLogger.info(_tag, 'Fetching courses and enrollments');
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final token = AuthCache.token;
    if (token == null) {
      AppLogger.warning(_tag, 'AuthCache.token is null — proceeding anyway for test flow');
    }

    try {
      AppLogger.debug(_tag, 'Calling getCourses()...');
      final coursesResult = await _learning.getCourses();
      AppLogger.debug(_tag, 'Courses response: isSuccess=${coursesResult.isSuccess}');

      AppLogger.debug(_tag, 'Calling getMyEnrollments()...');
      final enrollmentsResult = await _learning.getMyEnrollments();
      AppLogger.debug(_tag, 'Enrollments response: isSuccess=${enrollmentsResult.isSuccess}');

      /// ALL COURSES
      if (coursesResult.isSuccess) {
        courses = coursesResult.data ?? [];
        AppLogger.info(_tag, 'Courses loaded: ${courses.length}');
      } else {
        courses = [];
        AppLogger.error(_tag, 'Failed to load courses: ${coursesResult.error?.message}');
      }

      /// ENROLLMENTS
      if (enrollmentsResult.isSuccess) {
        enrollments = enrollmentsResult.data ?? [];
        AppLogger.info(_tag, 'Enrollments loaded: ${enrollments.length}');
      } else {
        enrollments = [];
        AppLogger.error(_tag, 'Failed to load enrollments: ${enrollmentsResult.error?.message}');
      }
    } catch (e) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Error in fetchCourses', e);
    } finally {
      AppLogger.debug(_tag, 'fetchCourses completed');
      isLoading = false;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  /// Only enrolled courses (for My Courses screen)
  Future<void> fetchMyCourses() async {
    AppLogger.info(_tag, 'Fetching my courses');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _learning.getMyEnrollments();
      AppLogger.debug(_tag, 'Enrollments response: isSuccess=${result.isSuccess}');

      if (result.isSuccess) {
        enrollments = result.data ?? [];
        AppLogger.info(_tag, 'My courses loaded: ${enrollments.length}');
      } else {
        enrollments = [];
        AppLogger.error(_tag, 'Failed to load my courses: ${result.error?.message}');
      }
    } catch (e) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Error in fetchMyCourses', e);
      enrollments = [];
    } finally {
      AppLogger.debug(_tag, 'fetchMyCourses completed');
      isLoading = false;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  /// Update course progress via PUT API.
  ///
  /// Returns a [ProgressUpdateResult] so the UI layer can show
  /// appropriate messages (success, rewards, retry restriction, error).
  Future<ProgressUpdateResult> updateCourseProgress(
    String courseId, {
    required List<String> completedLectures,
  }) async {
    // Prevent duplicate concurrent requests
    if (_isProgressUpdating) {
      AppLogger.warning(_tag, 'Progress update already in progress — skipping duplicate');
      return const ProgressUpdateResult(
        success: false,
        message: 'Update already in progress',
      );
    }

    _isProgressUpdating = true;
    AppLogger.info(
      _tag,
      'Updating progress for course $courseId: '
      '${completedLectures.length} completed lectures',
    );

    try {
      final result = await _learning.updateProgress(
        courseId,
        completedLectures: completedLectures,
      );

      if (result.isSuccess && result.data != null) {
        final progressModel = result.data!;
        AppLogger.info(
          _tag,
          'Progress updated: ${progressModel.progress}% '
          'status=${progressModel.status} '
          'rewards=(pts:${progressModel.rewards.pointsEarned}, xp:${progressModel.rewards.xpEarned})',
        );

        // Update local enrollment progress if we have it cached
        final enrollmentIndex = enrollments.indexWhere(
          (e) => e.course.id == courseId,
        );
        if (enrollmentIndex != -1) {
          // Reconstruct enrollment with updated progress
          final oldEnrollment = enrollments[enrollmentIndex];
          enrollments[enrollmentIndex] = Enrollment(
            id: oldEnrollment.id,
            course: oldEnrollment.course,
            completedModules: progressModel.completedLectures.length,
            progress: progressModel.progress,
            lastAccessed: progressModel.lastAccessed,
          );
          notifyListeners();
        }

        return ProgressUpdateResult(
          success: true,
          message: 'Progress updated successfully',
          progress: progressModel,
        );
      } else {
        final errorMsg = result.error?.message ?? 'Failed to update progress';
        AppLogger.error(_tag, 'Progress update failed: $errorMsg');

        // Check for retry restriction
        if (errorMsg.toLowerCase().contains('retry after')) {
          return ProgressUpdateResult(
            success: false,
            message: 'You can retry this assessment after 24 hours.',
            isRetryRestricted: true,
          );
        }

        return ProgressUpdateResult(
          success: false,
          message: errorMsg,
        );
      }
    } catch (e) {
      AppLogger.error(_tag, 'Progress update exception', e);

      // Check for network errors
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socket') ||
          errorStr.contains('network') ||
          errorStr.contains('connection')) {
        return const ProgressUpdateResult(
          success: false,
          message: 'Unable to connect. Please check internet.',
        );
      }

      return ProgressUpdateResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      _isProgressUpdating = false;
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
