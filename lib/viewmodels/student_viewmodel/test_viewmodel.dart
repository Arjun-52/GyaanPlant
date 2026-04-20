import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/student_role_models/assessment_model.dart';
import 'package:gyaanplant/services/student_services/test_service.dart';

class TestViewModel extends ChangeNotifier {
  static const _tag = 'TestViewModel';
  final TestService _service = TestService();

  List<AssessmentModel> tests = [];
  bool isLoading = false;
  bool isLoaded = false;
  int? selectedOption;
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

  Future<void> fetchTests() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      tests = await _service.getTests();
      isLoaded = true;
      AppLogger.info(_tag, 'Loaded ${tests.length} assessments');
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to fetch tests', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectOption(int index) {
    selectedOption = index;
    notifyListeners();
  }
}
