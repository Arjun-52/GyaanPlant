import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../../data/services/api_service.dart';
import '../../models/assessment/mock_test_models.dart';
import '../../models/assessment/problem_model.dart';

class TestViewModel extends ChangeNotifier {
  static const _tag = 'TestViewModel';

  final _assessment = ApiService().assessment;

  List<CompanyTagModel> companies = [];
  String? selectedCompany;
  AssessmentStatsModel? stats;
  CurrentAssessmentModel? currentAssessment;
  List<AvailableTestModel> availableTests = [];
  List<PreparationPackModel> packs = [];
  bool isPrepPacksLoading = false;
  int currentPrepPackPage = 1;
  int totalPrepPackPages = 1;
  int totalPrepPacksCount = 0;
  
  List<ProblemModel> problems = [];
  bool isProblemsLoading = false;
  int currentPage = 1;
  int totalPages = 1;
  int totalProblemsCount = 0;
  
  String searchQuery = '';
  String selectedDifficulty = 'ALL';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setSelectedDifficulty(String difficulty) {
    selectedDifficulty = difficulty;
    notifyListeners();
  }

  Future<void> searchProblems(String query) async {
    searchQuery = query;
    await fetchProblems(page: 1);
  }

  List<ProblemModel> get filteredProblems {
    List<ProblemModel> list = problems;
    if (selectedCompany != null && selectedCompany!.trim().isNotEmpty) {
      final comp = selectedCompany!.toLowerCase().trim();
      list = list.where((p) => p.tags.any((t) => t.toLowerCase().trim() == comp)).toList();
    }
    if (selectedDifficulty != 'ALL') {
      list = list.where((p) => p.difficulty.toLowerCase() == selectedDifficulty.toLowerCase()).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((p) => p.title.toLowerCase().contains(q) || p.description.toLowerCase().contains(q)).toList();
    }
    return list;
  }

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

  Future<void> fetchPrepPacks({int page = 1}) async {
    isPrepPacksLoading = true;
    notifyListeners();

    try {
      final res = await _assessment.getPreparationPacks(page: page, limit: 12);
      if (res.isSuccess && res.data != null) {
        packs = res.data!.packs;
        currentPrepPackPage = res.data!.pagination.page;
        totalPrepPackPages = res.data!.pagination.pages;
        totalPrepPacksCount = res.data!.pagination.total;
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch prep packs: $e');
    } finally {
      isPrepPacksLoading = false;
      notifyListeners();
    }
  }

  void changePrepPacksPage(int page) {
    if (page >= 1 && page <= totalPrepPackPages) {
      fetchPrepPacks(page: page);
    }
  }

  Future<void> fetchProblems({int page = 1}) async {
    isProblemsLoading = true;
    notifyListeners();

    try {
      final res = await _assessment.getProblems(
        page: page,
        search: searchQuery,
      );
      if (res.isSuccess && res.data != null) {
        problems = res.data!.problems;
        currentPage = res.data!.pagination.page;
        totalPages = res.data!.pagination.pages;
        totalProblemsCount = res.data!.pagination.total;

        // Stats card bindings:
        // Correct: count solved=true
        // Wrong: 0 if no API
        // Remaining: total - solved count
        // Accuracy: (solved/total)*100
        final solvedCount = problems.where((p) => p.solved).length;
        final total = totalProblemsCount;
        final remaining = total - solvedCount;
        final accuracy = total > 0 ? ((solvedCount / total) * 100).round() : 0;

        stats = AssessmentStatsModel(
          correct: solvedCount,
          wrong: 0,
          remaining: remaining,
          accuracy: accuracy,
        );
      } else {
        errorMessage = res.error?.message ?? "Failed to fetch practice problems";
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch problems: $e');
      errorMessage = e.toString();
    } finally {
      isProblemsLoading = false;
      notifyListeners();
    }
  }

  void changeProblemsPage(int page) {
    if (page >= 1 && page <= totalPages) {
      fetchProblems(page: page);
    }
  }

  Future<void> fetchTests() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        fetchCompanies(),
        fetchCurrentAssessment(),
        fetchAvailableTests(),
        fetchPrepPacks(page: 1),
        fetchProblems(page: 1),
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
    notifyListeners(); // Notify instantly so local list filters reactively
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
