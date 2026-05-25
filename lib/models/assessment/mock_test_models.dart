class CompanyTagModel {
  final String id;
  final String name;

  CompanyTagModel({required this.id, required this.name});

  factory CompanyTagModel.fromJson(Map<String, dynamic> json) =>
      CompanyTagModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );
}

class AssessmentStatsModel {
  final int correct;
  final int wrong;
  final int remaining;
  final int accuracy;

  AssessmentStatsModel({
    required this.correct,
    required this.wrong,
    required this.remaining,
    required this.accuracy,
  });

  factory AssessmentStatsModel.fromJson(Map<String, dynamic> json) =>
      AssessmentStatsModel(
        correct: json['correct'] as int? ?? 0,
        wrong: json['wrong'] as int? ?? 0,
        remaining: json['remaining'] as int? ?? 0,
        accuracy: json['accuracy'] as int? ?? 0,
      );
}

class CurrentAssessmentModel {
  final bool hasAssessment;
  final String? title;
  final int? questionNumber;
  final int? totalQuestions;

  CurrentAssessmentModel({
    required this.hasAssessment,
    this.title,
    this.questionNumber,
    this.totalQuestions,
  });

  factory CurrentAssessmentModel.fromJson(Map<String, dynamic> json) =>
      CurrentAssessmentModel(
        hasAssessment: json['hasAssessment'] as bool? ?? false,
        title: json['title'] as String?,
        questionNumber: json['questionNumber'] as int?,
        totalQuestions: json['totalQuestions'] as int?,
      );
}

class AvailableTestModel {
  final String id;
  final String title;
  final int questions;
  final String duration;

  AvailableTestModel({
    required this.id,
    required this.title,
    required this.questions,
    required this.duration,
  });

  factory AvailableTestModel.fromJson(Map<String, dynamic> json) =>
      AvailableTestModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        questions: json['questions'] as int? ?? 0,
        duration: json['duration']?.toString() ?? '',
      );
}

class PreparationPackModel {
  final String id;
  final String title;
  final int price;

  PreparationPackModel({
    required this.id,
    required this.title,
    required this.price,
  });

  factory PreparationPackModel.fromJson(Map<String, dynamic> json) =>
      PreparationPackModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        price: json['price'] as int? ?? 0,
      );
}
