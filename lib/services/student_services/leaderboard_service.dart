import 'dart:convert';
import '../../core/utils/app_logger.dart';
import '../../models/student_role_models/leaderboard_model.dart';
import 'base_api_service.dart';

class LeaderboardService {
  static const String _tag = 'LeaderboardService';

  Future<List<LeaderboardUser>> getLeaderboard() async {
    AppLogger.info(_tag, 'Fetching leaderboard');
    try {
      final response = await BaseApiService.get('/api/v1/gamification/leaderboard');
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List list = (data['data'] as List?) ?? [];
      final users = list.map((e) => LeaderboardUser.fromJson(e as Map<String, dynamic>)).toList();
      AppLogger.info(_tag, 'Fetched ${users.length} leaderboard entries');
      return users;
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to fetch leaderboard', e, st);
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }
}
