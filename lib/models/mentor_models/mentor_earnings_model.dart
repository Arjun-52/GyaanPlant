class MentorEarningsModel {
  final Stats stats;
  final List<dynamic> recentSessions;
  final List<int> chartData;

  MentorEarningsModel({
    required this.stats,
    required this.recentSessions,
    required this.chartData,
  });

  factory MentorEarningsModel.fromJson(Map<String, dynamic> json) {
    return MentorEarningsModel(
      stats: Stats.fromJson(json["stats"] ?? {}),
      recentSessions: json["recentSessions"] ?? [],
      chartData: List<int>.from(
        (json["chartData"] as List? ?? []).map((e) => (e as num).toInt()),
      ),
    );
  }
}

class Stats {
  final double totalEarnings;
  final double monthlyEarnings;
  final double netEarnings;
  final int sessionsCompleted;
  final double pendingClearance;

  Stats({
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.netEarnings,
    required this.sessionsCompleted,
    required this.pendingClearance,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalEarnings: (json["totalEarnings"] ?? 0).toDouble(),
      monthlyEarnings: (json["monthlyEarnings"] ?? 0).toDouble(),
      netEarnings: (json["netEarnings"] ?? 0).toDouble(),
      sessionsCompleted: json["sessionsCompleted"] ?? 0,
      pendingClearance: (json["pendingClearance"] ?? 0).toDouble(),
    );
  }
}
