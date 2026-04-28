import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../../data/services/api_service.dart';
import '../../models/learning/learning_model.dart';

class LearningViewModel extends ChangeNotifier {
  static const _tag = 'LearningViewModel';

  final _learning = ApiService().learning;

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
      final result = await _learning.getCourses();
      if (result.isSuccess) {
        courses = result.data!;
        isLoaded = true;
        AppLogger.info(_tag, 'Loaded ${courses.length} courses');
      } else {
        errorMessage = result.error?.message ?? 'Failed to fetch courses';
        AppLogger.error(_tag, errorMessage!);
      }
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to fetch courses', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }
}
