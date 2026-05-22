import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/mentor_earnings_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';

class MentorEarningsController extends ChangeNotifier {
  final _apiService = ApiService();

  MentorEarningsModel? earnings;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchEarnings() async {
    AppLogger.info('MentorEarningsController', '🔄 Starting fetchEarnings');
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.getMentorEarnings();
      if (result.success && result.data != null) {
        earnings = result.data;
        AppLogger.info('MentorEarningsController', '✅ Mentor earnings loaded successfully');
      } else {
        errorMessage = result.error?.message ?? result.message ?? 'Failed to load earnings';
        AppLogger.error('MentorEarningsController', '❌ Failed to load earnings: $errorMessage');
      }
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error('MentorEarningsController', '❌ Exception in fetchEarnings', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
