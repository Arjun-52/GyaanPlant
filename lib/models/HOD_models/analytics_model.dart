class AnalyticsModel {
  final List<int> monthlyActive;
  final List<int> placementRates;
  final int activeStudents;
  final double avgHours;
  final int readinessScore;
  final int certificates;

  AnalyticsModel({
    required this.monthlyActive,
    required this.placementRates,
    required this.activeStudents,
    required this.avgHours,
    required this.readinessScore,
    required this.certificates,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      monthlyActive: (json["monthlyActive"] as List? ?? [])
          .map((e) => e as int)
          .toList(),

      placementRates: (json["placementRates"] as List? ?? [])
          .map((e) => e as int)
          .toList(),

      activeStudents: json["activeStudents"] ?? 0,
      avgHours: (json["avgHours"] ?? 0).toDouble(),
      readinessScore: json["readinessScore"] ?? 0,
      certificates: json["certificates"] ?? 0,
    );
  }
}
