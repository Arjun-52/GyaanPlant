class LeaderboardEntry {
  final String userId;
  final String name;
  final String? avatar;
  final int points;
  final int xp;
  final int level;
  final String collarType;
  final String? department;
  final String profileType;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    this.avatar,
    required this.points,
    required this.xp,
    required this.level,
    required this.collarType,
    this.department,
    required this.profileType,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        userId: json['user'] as String,
        name: json['name'] as String,
        avatar: json['avatar'] as String?,
        points: json['points'] as int? ?? 0,
        xp: json['xp'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        collarType: json['collarType'] as String? ?? 'student',
        department: json['department'] as String?,
        profileType: json['profileType'] as String? ?? 'student',
        rank: json['rank'] as int? ?? 0,
      );
}

class LeaderboardMeta {
  final String scope;
  final String? scopeId;
  final String period;
  final String audience;

  const LeaderboardMeta({
    required this.scope,
    this.scopeId,
    required this.period,
    required this.audience,
  });

  factory LeaderboardMeta.fromJson(Map<String, dynamic> json) => LeaderboardMeta(
        scope: json['scope'] as String? ?? 'global',
        scopeId: json['scopeId'] as String?,
        period: json['period'] as String? ?? 'all_time',
        audience: json['audience'] as String? ?? 'all',
      );
}

class LeaderboardResponse {
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? myRank;
  final LeaderboardMeta meta;

  const LeaderboardResponse({
    required this.entries,
    this.myRank,
    required this.meta,
  });
}
