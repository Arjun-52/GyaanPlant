import '../models/gamification/leaderboard_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class GamificationRepository {
  final NetworkAPIManager _api;

  GamificationRepository(this._api);

  Future<ApiResponse<LeaderboardResponse>> getLeaderboard({
    String scope = 'global',
    String period = 'all_time',
    String audience = 'all',
  }) {
    return _api.get<LeaderboardResponse>(
      ApiEndpoints.leaderboard,
      queryParameters: {
        'scope': scope,
        'period': period,
        'audience': audience,
      },
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;
        final myRankRaw = map['myRank'] as Map<String, dynamic>?;
        return LeaderboardResponse(
          entries: list
              .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
          myRank: myRankRaw != null
              ? LeaderboardEntry.fromJson(myRankRaw)
              : null,
          meta: LeaderboardMeta.fromJson(
            map['meta'] as Map<String, dynamic>? ?? {},
          ),
        );
      },
    );
  }
}
