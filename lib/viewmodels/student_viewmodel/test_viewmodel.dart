import 'package:flutter/material.dart';

import 'package:gyaanplant/models/student_role_models/assessment_model.dart';
import 'package:gyaanplant/services/student_services/test_service.dart';

class TestViewModel extends ChangeNotifier {
  final TestService _service = TestService();

  List<AssessmentModel> tests = [];
  bool isLoading = false;
  int? selectedOption;

  Future<void> fetchTests() async {
    isLoading = true;
    notifyListeners();

    try {
      tests = await _service.getTests();
    } catch (e) {
      print('Error fetching tests: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void selectOption(int index) {
    selectedOption = index;
    notifyListeners();
  }
}
