import 'package:flutter/material.dart';
import 'package:gyaanplant/services/student_services/learning_service.dart';

class LearningViewModel extends ChangeNotifier {
  final LearningService _service = LearningService();

  List enrollments = [];
  bool isLoading = false;

  Future<void> fetchEnrollments(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      enrollments = await _service.getMyEnrollments(token);
      print("ENROLLMENTS API RESPONSE: $enrollments");
      print("ENROLLMENTS COUNT: ${enrollments.length}");

      // TEMPORARY: Add mock data if API returns empty
      if (enrollments.isEmpty) {
        print("🧪 ADDING MOCK DATA FOR TESTING");
        enrollments = [
          {
            'course': {
              'title': 'Test Course 1',
              'totalModules': 10,
              'category': 'programming',
            },
            'progress': 50,
            'completedModules': 5,
          },
          {
            'course': {
              'title': 'Test Course 2',
              'totalModules': 8,
              'category': 'data',
            },
            'progress': 25,
            'completedModules': 2,
          },
        ];
        print("🧪 MOCK DATA ADDED: ${enrollments.length} courses");
      }
    } catch (e) {
      print("Error: $e");

      // TEMPORARY: Add mock data on error too
      print("🧪 API ERROR - ADDING MOCK DATA");
      enrollments = [
        {
          'course': {
            'title': 'Error Test Course',
            'totalModules': 5,
            'category': 'test',
          },
          'progress': 0,
          'completedModules': 0,
        },
      ];
    }

    isLoading = false;
    notifyListeners();
  }
}
