import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../../data/services/api_service.dart';
import '../../models/assessment/mock_test_models.dart';

class TestViewModel extends ChangeNotifier {
  static const _tag = 'TestViewModel';

  final _assessment = ApiService().assessment;

  List<CompanyTagModel> companies = [];
  String? selectedCompany;
  AssessmentStatsModel? stats;
  CurrentAssessmentModel? currentAssessment;
  List<AvailableTestModel> availableTests = [];
  List<PreparationPackModel> packs = [];

  bool isLoading = false;
  String? errorMessage;
  int currentTestIndex = 0;
  int? selectedOption;
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

  Future<void> fetchCompanies() async {
    try {
      final res = await _assessment.getCompanies();
      if (res.isSuccess) {
        companies = res.data ?? [];
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch companies: $e');
    }
  }

  Future<void> fetchStats() async {
    try {
      final res = await _assessment.getStats();
      if (res.isSuccess) {
        stats = res.data;
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch stats: $e');
    }
  }

  Future<void> fetchCurrentAssessment() async {
    try {
      final res = await _assessment.getCurrentAssessment();
      if (res.isSuccess) {
        currentAssessment = res.data;
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch current assessment: $e');
    }
  }

  Future<void> fetchAvailableTests() async {
    try {
      final res = await _assessment.getAvailableTests(company: selectedCompany);
      if (res.isSuccess) {
        availableTests = res.data ?? [];
        currentTestIndex = 0; // Reset index when list changes
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch available tests: $e');
    }
  }

  Future<void> fetchPrepPacks() async {
    try {
      final res = await _assessment.getPreparationPacks();
      if (res.isSuccess) {
        packs = res.data ?? [];
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch prep packs: $e');
    }
  }

  Future<void> fetchTests() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        fetchCompanies(),
        fetchStats(),
        fetchCurrentAssessment(),
        fetchAvailableTests(),
        fetchPrepPacks(),
      ]);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCompany(String companyName) {
    if (selectedCompany == companyName) {
      selectedCompany = null; // Unselect if tapped again
    } else {
      selectedCompany = companyName;
    }
    // Reload tests when company chip is changed
    isLoading = true;
    notifyListeners();
    fetchAvailableTests().then((_) {
      isLoading = false;
      notifyListeners();
    });
  }

  void selectOption(int index) {
    selectedOption = index;
    notifyListeners();
  }

  void nextTest() {
    if (availableTests.isNotEmpty && currentTestIndex < availableTests.length - 1) {
      currentTestIndex++;
      selectedOption = null; // Reset selection on question change
      notifyListeners();
    }
  }

  void previousTest() {
    if (currentTestIndex > 0) {
      currentTestIndex--;
      selectedOption = null; // Reset selection on question change
      notifyListeners();
    }
  }
}
