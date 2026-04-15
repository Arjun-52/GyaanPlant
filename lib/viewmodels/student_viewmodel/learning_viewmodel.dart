import 'package:flutter/material.dart';
import 'package:gyaanplant/models/student_role_models/course_model.dart';
import 'package:gyaanplant/services/student_services/learning_service.dart';

class LearningViewModel extends ChangeNotifier {
  final LearningService _service = LearningService();

  List<CourseModel> courses = [];
  bool isLoading = false;
  bool isLoaded = false;

  Future<void> fetchCourses() async {
    if (isLoaded) return;

    isLoading = true;
    notifyListeners();

    try {
      courses = await _service.getCourses();
      isLoaded = true;
    } catch (e) {
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }
}
