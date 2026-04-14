import 'package:flutter/material.dart';
import 'package:gyaanplant/models/course_model.dart';
import 'package:gyaanplant/services/learning_service.dart';

class LearningViewModel extends ChangeNotifier {
  final LearningService _service = LearningService();

  List<CourseModel> courses = [];
  bool isLoading = false;

  Future<void> fetchCourses() async {
    isLoading = true;
    notifyListeners();

    try {
      courses = await _service.getCourses();
    } catch (e) {
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }
}
