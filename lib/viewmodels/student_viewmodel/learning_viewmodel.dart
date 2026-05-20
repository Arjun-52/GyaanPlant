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
<<<<<<< Updated upstream
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
=======
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
>>>>>>> Stashed changes
    }
  }

  Future<void> fetchMyCourses() async {
<<<<<<< Updated upstream
=======
    print("🚀 [LearningViewModel] FETCH MY COURSES. Setting isLoading = true");

>>>>>>> Stashed changes
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print("🚀 [LearningViewModel] Calling _learning.getMyEnrollments()...");
      final result = await _learning.getMyEnrollments();
<<<<<<< Updated upstream
      enrollments = result.isSuccess ? (result.data ?? []) : [];
      AppLogger.info(_tag, 'Loaded ${enrollments.length} enrolled courses');
    } catch (e, st) {
      enrollments = [];
      AppLogger.error(_tag, 'Failed to fetch my courses', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
=======
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
>>>>>>> Stashed changes
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
