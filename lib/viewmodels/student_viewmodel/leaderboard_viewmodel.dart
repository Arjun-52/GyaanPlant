import 'package:flutter/material.dart';
import 'package:gyaanplant/models/leaderboard_model.dart';
import 'package:gyaanplant/services/leaderboard_service.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final LeaderboardService _service = LeaderboardService();

  List<LeaderboardUser> users = [];
  bool isLoading = false;

  Future<void> fetchLeaderboard() async {
    isLoading = true;
    notifyListeners();

    try {
      users = await _service.getLeaderboard();
    } catch (e) {
      print("Leaderboard error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
