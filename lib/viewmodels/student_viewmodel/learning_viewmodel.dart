import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/student_role_models/course_model.dart';
import 'package:gyaanplant/services/student_services/learning_service.dart';

class LearningViewModel extends ChangeNotifier {
  static const _tag = 'LearningViewModel';
  final LearningService _service = LearningService();

  List<CourseModel> courses = [];
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

  Future<void> fetchCourses() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      courses = await _service.getCourses();
      isLoaded = true;
      AppLogger.info(_tag, 'Loaded ${courses.length} courses');
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to fetch courses', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
