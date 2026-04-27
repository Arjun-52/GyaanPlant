class AnalyticsModel {
  final List<int> monthlyActive;
  final List<int> placementRates;
  final int activeStudents;
  final double avgHours;
  final int readinessScore;
  final int certificates;

  // New fields for requirements
  final List<dynamic> departments;
  final List<dynamic> readiness;
  final Map<String, dynamic> placementStats;
  final List<dynamic> topPerformers;
  final List<dynamic> lowPerformers;

  AnalyticsModel({
    required this.monthlyActive,
    required this.placementRates,
    required this.activeStudents,
    required this.avgHours,
    required this.readinessScore,
    required this.certificates,
    required this.departments,
    required this.readiness,
    required this.placementStats,
    required this.topPerformers,
    required this.lowPerformers,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    print("ANALYTICS MODEL PARSING JSON: $json");

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

      // New fields with null safety
      departments: json["departments"] ?? [],
      readiness: json["readiness"] ?? [],
      placementStats: json["placementStats"] ?? {},
      topPerformers: json["topPerformers"] ?? [],
      lowPerformers: json["lowPerformers"] ?? [],
    );
  }
}
