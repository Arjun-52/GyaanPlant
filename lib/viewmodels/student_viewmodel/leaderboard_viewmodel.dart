import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../../data/services/api_service.dart';
import '../../models/gamification/leaderboard_model.dart';

class LeaderboardViewModel extends ChangeNotifier {
  static const _tag = 'LeaderboardViewModel';

  final _gamification = ApiService().gamification;

  List<LeaderboardEntry> entries = [];

  // Alias kept for view compatibility
  List<LeaderboardEntry> get users => entries;
  LeaderboardEntry? myRank;
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
      final result = await _gamification.getLeaderboard();
      if (result.isSuccess) {
        entries = result.data!.entries;
        myRank = result.data!.myRank;
        isLoaded = true;
        AppLogger.info(_tag, 'Loaded ${entries.length} leaderboard entries');
      } else {
        errorMessage = result.error?.message ?? 'Failed to fetch leaderboard';
        AppLogger.error(_tag, errorMessage!);
      }
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to fetch leaderboard', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }
}
