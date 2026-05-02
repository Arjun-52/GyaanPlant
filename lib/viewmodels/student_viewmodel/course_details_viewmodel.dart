import 'package:flutter/material.dart';

class CourseDetailsViewModel extends ChangeNotifier {
  final _learning = ApiService().learning;

  CourseModel? course;
  bool isLoading = false;
  String? error;

  Future<void> fetchCourse(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      course = await _learning.getCourseById(id);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
