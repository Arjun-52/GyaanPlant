import 'dart:convert';

import '../models/leaderboard_model.dart';
import 'base_api_service.dart';

class LeaderboardService {
  Future<List<LeaderboardUser>> getLeaderboard() async {
    try {
      final response = await BaseApiService.get(
        '/api/v1/gamification/leaderboard',
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      print("📄 Leaderboard Response: $data");

      final List list = data['data'];

      return list.map((e) => LeaderboardUser.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to fetch leaderboard: $e");
    }
  }
}
