import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/HOD_models/naac_model.dart';

class NaacViewModel extends ChangeNotifier {
  static const _tag = 'NaacViewModel';

  NaacModel? naac;
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

  Future<void> fetchNaac() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TODO: replace with real API call
      await Future.delayed(const Duration(seconds: 1));

      naac = NaacModel(
        grade: 'A+',
        validTill: 2028,
        criteria: [
          NaacCriterion(title: 'Curricular Aspects', score: 3.4),
          NaacCriterion(title: 'Teaching & Learning', score: 3.6),
          NaacCriterion(title: 'Research & Innovation', score: 3.2),
          NaacCriterion(title: 'Infrastructure', score: 3.5),
          NaacCriterion(title: 'Student Support (Placement)', score: 3.8),
          NaacCriterion(title: 'Governance', score: 3.3),
        ],
      );
      isLoaded = true;
      AppLogger.info(_tag, 'NAAC data loaded');
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to load NAAC data', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
