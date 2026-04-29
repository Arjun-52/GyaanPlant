import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../../data/services/api_service.dart';
import '../../models/learning/learning_model.dart';
import '../../models/prep_pack_model.dart';

class TestViewModel extends ChangeNotifier {
  static const _tag = 'TestViewModel';

  final _learning = ApiService().learning;

  List<AssessmentModel> tests = [];
  List<PrepPack> packs = [];
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
      final result = await _learning.getAssessments();
      if (result.isSuccess) {
        tests = result.data!;
        isLoaded = true;
        AppLogger.info(_tag, 'Loaded ${tests.length} assessments');
      } else {
        errorMessage = result.error?.message ?? 'Failed to fetch tests';
        AppLogger.error(_tag, errorMessage!);
      }
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to fetch tests', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void selectOption(int index) {
    selectedOption = index;
    notifyListeners();
  }

  Future<void> fetchPrepPacks() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _learning.getPrepPacks();
      packs = response.data ?? [];

      print("📦 PACKS COUNT: ${packs.length}");
    } catch (e) {
      print("Error fetching packs: $e");
      packs = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startPackAttempt(String packId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _learning.startAttempt(packId);

      print("🚀 ATTEMPT STARTED: ${response.isSuccess}");

      if (response.isSuccess) {
        // Navigate to test screen or handle success
        print("✅ ATTEMPT SUCCESS: ${response.data}");
      } else {
        print("❌ ATTEMPT FAILED: ${response.error}");
      }
    } catch (e) {
      print("💥 ATTEMPT ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
