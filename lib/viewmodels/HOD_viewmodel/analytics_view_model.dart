import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/HOD_models/analytics_model.dart';

class AnalyticsViewModel extends ChangeNotifier {
  static const _tag = 'AnalyticsViewModel';

  AnalyticsModel? analytics;
  bool isLoading = false;
  bool isLoaded = false;
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

  Future<void> fetchAnalytics() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TODO: replace with real API call
      await Future.delayed(const Duration(seconds: 1));

      analytics = AnalyticsModel(
        activeStudents: 2076,
        growthPercent: 8,
        avgHours: 12.4,
        readinessScore: 67,
        certificates: 1240,
      );
      isLoaded = true;
      AppLogger.info(_tag, 'Analytics loaded');
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to load analytics', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
