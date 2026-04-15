import 'package:flutter/material.dart';
import 'package:gyaanplant/models/student_role_models/leaderboard_model.dart';
import 'package:gyaanplant/services/student_services/leaderboard_service.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final LeaderboardService _service = LeaderboardService();

  List<LeaderboardUser> users = [];
  bool isLoading = false;
  bool isLoaded = false;

  Future<void> fetchLeaderboard() async {
    if (isLoaded) return;

    isLoading = true;
    notifyListeners();

    try {
      users = await _service.getLeaderboard();
      isLoaded = true;
    } catch (e) {
      print("Leaderboard error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
