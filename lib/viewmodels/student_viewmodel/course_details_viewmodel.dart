import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/learning/learning_model.dart';

class CourseDetailsViewModel extends ChangeNotifier {
  static const _tag = 'CourseDetailsViewModel';

  final _learning = ApiService().learning;

  CourseModel? course;
  bool isLoading = false;
  String? error;
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

  Future<void> fetchCourse(String id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _learning.getCourseById(id);
      if (result.isSuccess && result.data != null) {
        course = result.data;
        AppLogger.info(_tag, 'Course loaded: ${course?.title}');
      } else {
        error = result.error?.message ?? 'Failed to load course';
        AppLogger.error(_tag, error!);
      }
    } catch (e, st) {
      error = e.toString();
      AppLogger.error(_tag, 'Failed to fetch course', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }
}
