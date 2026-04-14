class AssessmentModel {
  final String id;
  final String title;
  final String skill;

  AssessmentModel({
    required this.id,
    required this.title,
    required this.skill,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['_id'],
      title: json['title'] ?? '',
      skill: json['skill'] ?? '',
    );
  }
}