class AnalyticsModel {
  final int activeStudents;
  final int growthPercent;
  final double avgHours;
  final int readinessScore;
  final int certificates;

  AnalyticsModel({
    required this.activeStudents,
    required this.growthPercent,
    required this.avgHours,
    required this.readinessScore,
    required this.certificates,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      activeStudents: json['activeStudents'] ?? 0,
      growthPercent: json['growthPercent'] ?? 0,
      avgHours: (json['avgHours'] ?? 0).toDouble(),
      readinessScore: json['readinessScore'] ?? 0,
      certificates: json['certificates'] ?? 0,
    );
  }
}
