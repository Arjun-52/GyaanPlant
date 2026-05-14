class NaacModel {
  final String grade;
  final int validTill;
  final List<NaacCriterion> criteria;

  NaacModel({
    required this.grade,
    required this.validTill,
    required this.criteria,
  });

  factory NaacModel.fromJson(Map<String, dynamic> json) {
    return NaacModel(
      grade: json['grade'] ?? 'A+',
      validTill: json['validTill'] ?? 2028,
      criteria: (json['criteria'] as List? ?? [])
          .map((e) => NaacCriterion.fromJson(e))
          .toList(),
    );
  }
}

class NaacCriterion {
  final String title;
  final double score;

  NaacCriterion({required this.title, required this.score});

  factory NaacCriterion.fromJson(Map<String, dynamic> json) {
    return NaacCriterion(
      title: json['title'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
    );
  }
}
