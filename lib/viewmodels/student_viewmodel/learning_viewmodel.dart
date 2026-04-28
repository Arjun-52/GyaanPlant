import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class LearningViewModel extends ChangeNotifier {
  final _learning = ApiService().learning;

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
      final result = await _learning.getMyEnrollments();
      if (result.isSuccess) {
        enrollments = result.data!;
      } else {
        errorMessage = result.error?.message ?? 'Failed to fetch enrollments';
        enrollments = [];
      }
    } catch (e) {
      errorMessage = e.toString();
      enrollments = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
