import 'package:flutter/material.dart';
import 'package:gyaanplant/services/student_services/learning_service.dart';

class LearningViewModel extends ChangeNotifier {
  final _service = LearningService();

  List enrollments = [];
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

  Future<void> fetchEnrollments(String token) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      enrollments = await _service.getMyEnrollments(token);
    } catch (e) {
      errorMessage = e.toString();
      enrollments = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
