import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/student_role_models/leaderboard_model.dart';
import 'package:gyaanplant/services/student_services/leaderboard_service.dart';

class LeaderboardViewModel extends ChangeNotifier {
  static const _tag = 'LeaderboardViewModel';
  final LeaderboardService _service = LeaderboardService();

  List<LeaderboardUser> users = [];
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

  Future<void> fetchLeaderboard() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      users = await _service.getLeaderboard();
      isLoaded = true;
      AppLogger.info(_tag, 'Loaded ${users.length} leaderboard entries');
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to fetch leaderboard', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
