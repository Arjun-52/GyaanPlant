import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import 'package:gyaanplant/network/auth_cache.dart';

class LearningViewModel extends ChangeNotifier {
  final _learning = ApiService().learning;

  List<Course> courses = [];
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
      final result = await _learning.getMyEnrollments();

      print("📦 RESPONSE: ${result.data}");

      if (result.isSuccess) {
        final enrollments = result.data;

        if (enrollments != null) {
          ///  Convert enrollments to courses list for other uses
          courses = enrollments.map((enrollment) => enrollment.course).toList();

          ///  Convert enrollments to JSON format for ActiveCoursesSection
          activeCourses = enrollments
              .map(
                (enrollment) => {
                  'course': {
                    '_id': enrollment.course.id,
                    'title': enrollment.course.title,
                    'description': enrollment.course.description,
                    'thumbnail': enrollment.course.thumbnail,
                    'category': enrollment.course.category,
                    'totalModules': enrollment.course.totalModules,
                  },
                  'completedModules': enrollment.completedModules ?? 0,
                  'progress': enrollment.progress ?? 0,
                  'lastAccessed': enrollment.lastAccessed?.toIso8601String(),
                  'hasAccess': true,
                  'enrollment': {'status': 'enrolled'},
                },
              )
              .toList();

          print("✅ TOTAL COURSES: ${courses.length}");
          print("✅ ACTIVE COURSES: ${activeCourses.length}");
        } else {
          courses = [];
          activeCourses = [];
          print("⚠️ NO ENROLLMENT DATA");
        }
      } else {
        errorMessage = result.error?.message ?? 'Failed to fetch enrollments';
        courses = [];
        activeCourses = [];
      }
    } catch (e) {
      errorMessage = e.toString();
      courses = [];
      activeCourses = [];
      print("💥 ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
