class LeaderboardUser {
  final String name;
  final int xp;
  final int rank;

  LeaderboardUser({required this.name, required this.xp, required this.rank});

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    final rank = json['rank'] ?? 0;

    return LeaderboardUser(
      name: json['user'] is Map
          ? json['user']['name'] ?? "User"
          : "User #$rank",
      xp: json['xp'] ?? 0,
      rank: rank,
    );
  }
}
