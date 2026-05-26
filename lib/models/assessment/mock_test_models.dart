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
  final String difficulty;
  final bool isPremium;
  final int discountedPrice;
  final int discountPercentage;
  final List<dynamic> sections;
  final int totalQuestions;
  final int totalDurationMins;
  final int attempts;
  final int completions;
  final double avgScore;
  final double passingScore;
  final bool hasAccess;
  final List<String> tags;

  PreparationPackModel({
    required this.id,
    required this.title,
    required this.price,
    required this.difficulty,
    required this.isPremium,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.sections,
    required this.totalQuestions,
    required this.totalDurationMins,
    required this.attempts,
    required this.completions,
    required this.avgScore,
    required this.passingScore,
    required this.hasAccess,
    required this.tags,
  });

  factory PreparationPackModel.fromJson(Map<String, dynamic> json) {
    return PreparationPackModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: int.tryParse(json['price']?.toString() ?? '') ?? (json['price'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString() ?? 'mixed',
      isPremium: json['isPremium'] as bool? ?? false,
      discountedPrice: int.tryParse(json['discountedPrice']?.toString() ?? '') ?? (json['discountedPrice'] as num?)?.toInt() ?? 0,
      discountPercentage: int.tryParse(json['discountPercentage']?.toString() ?? '') ?? (json['discountPercentage'] as num?)?.toInt() ?? 0,
      sections: json['sections'] as List<dynamic>? ?? [],
      totalQuestions: int.tryParse(json['totalQuestions']?.toString() ?? '') ?? (json['totalQuestions'] as num?)?.toInt() ?? 0,
      totalDurationMins: int.tryParse(json['totalDurationMins']?.toString() ?? '') ?? (json['totalDurationMins'] as num?)?.toInt() ?? 0,
      attempts: int.tryParse(json['attempts']?.toString() ?? '') ?? (json['attempts'] as num?)?.toInt() ?? 0,
      completions: int.tryParse(json['completions']?.toString() ?? '') ?? (json['completions'] as num?)?.toInt() ?? 0,
      avgScore: double.tryParse(json['avgScore']?.toString() ?? '') ?? (json['avgScore'] as num?)?.toDouble() ?? 0.0,
      passingScore: double.tryParse(json['passingScore']?.toString() ?? '') ?? (json['passingScore'] as num?)?.toDouble() ?? 0.0,
      hasAccess: json['hasAccess'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class PreparationPackPaginationModel {
  final int total;
  final int page;
  final int pages;
  final int limit;

  PreparationPackPaginationModel({
    required this.total,
    required this.page,
    required this.pages,
    required this.limit,
  });

  factory PreparationPackPaginationModel.fromJson(Map<String, dynamic> json) =>
      PreparationPackPaginationModel(
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        pages: json['pages'] as int? ?? 1,
        limit: json['limit'] as int? ?? 12,
      );
}

class PreparationPacksResponseModel {
  final List<PreparationPackModel> packs;
  final PreparationPackPaginationModel pagination;

  PreparationPacksResponseModel({
    required this.packs,
    required this.pagination,
  });
}

class MarkingSchemeModel {
  final double correct;
  final double wrong;
  final double negative;

  MarkingSchemeModel({
    required this.correct,
    required this.wrong,
    required this.negative,
  });

  factory MarkingSchemeModel.fromJson(Map<String, dynamic> json) {
    return MarkingSchemeModel(
      correct: double.tryParse(json['correct']?.toString() ?? '') ?? (json['correct'] as num?)?.toDouble() ?? 4.0,
      wrong: double.tryParse(json['wrong']?.toString() ?? '') ?? (json['wrong'] as num?)?.toDouble() ?? 0.0,
      negative: double.tryParse(json['negative']?.toString() ?? '') ?? (json['negative'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class PrepPackQuestionModel {
  final String id;
  final String title;
  final String? description;
  final List<String> options;
  final int correctIndex;

  PrepPackQuestionModel({
    required this.id,
    required this.title,
    this.description,
    required this.options,
    required this.correctIndex,
  });

  factory PrepPackQuestionModel.fromJson(Map<String, dynamic> json) {
    var rawOptions = json['options'] as List<dynamic>? ?? [];
    List<String> parsedOptions = rawOptions.map((e) => e.toString()).toList();
    return PrepPackQuestionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      options: parsedOptions,
      correctIndex: int.tryParse(json['correctIndex']?.toString() ?? '') ?? (json['correctIndex'] as num?)?.toInt() ?? 0,
    );
  }
}

class PrepPackSectionModel {
  final String id;
  final String title;
  final int questionsCount;
  final int duration;
  final List<PrepPackQuestionModel> questions;

  PrepPackSectionModel({
    required this.id,
    required this.title,
    required this.questionsCount,
    required this.duration,
    required this.questions,
  });

  factory PrepPackSectionModel.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] as List<dynamic>? ?? [];
    List<PrepPackQuestionModel> parsedQuestions = rawQuestions
        .map((e) => PrepPackQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PrepPackSectionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      questionsCount: int.tryParse(json['questionsCount']?.toString() ?? '') ?? (json['questionsCount'] as num?)?.toInt() ?? parsedQuestions.length,
      duration: int.tryParse(json['duration']?.toString() ?? '') ?? (json['duration'] as num?)?.toInt() ?? 0,
      questions: parsedQuestions,
    );
  }
}

class PrepPackDetailsModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final int discountedPrice;
  final int discountPercentage;
  final String difficulty;
  final String targetType;
  final bool isPremium;
  final bool hasAccess;
  final int totalQuestions;
  final int totalDurationMins;
  final int attempts;
  final int completions;
  final double avgScore;
  final double passingScore;
  final List<String> targetCompanies;
  final List<String> targetRoles;
  final List<String> industries;
  final MarkingSchemeModel markingScheme;
  final List<PrepPackSectionModel> sections;

  PrepPackDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.difficulty,
    required this.targetType,
    required this.isPremium,
    required this.hasAccess,
    required this.totalQuestions,
    required this.totalDurationMins,
    required this.attempts,
    required this.completions,
    required this.avgScore,
    required this.passingScore,
    required this.targetCompanies,
    required this.targetRoles,
    required this.industries,
    required this.markingScheme,
    required this.sections,
  });

  factory PrepPackDetailsModel.fromJson(Map<String, dynamic> json) {
    var rawSections = json['sections'] as List<dynamic>? ?? [];
    List<PrepPackSectionModel> parsedSections = rawSections
        .map((e) => PrepPackSectionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    var rawCompanies = json['targetCompanies'] as List<dynamic>? ?? [];
    var rawRoles = json['targetRoles'] as List<dynamic>? ?? [];
    var rawIndustries = json['industries'] as List<dynamic>? ?? [];

    return PrepPackDetailsModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: int.tryParse(json['price']?.toString() ?? '') ?? (json['price'] as num?)?.toInt() ?? 0,
      discountedPrice: int.tryParse(json['discountedPrice']?.toString() ?? '') ?? (json['discountedPrice'] as num?)?.toInt() ?? 0,
      discountPercentage: int.tryParse(json['discountPercentage']?.toString() ?? '') ?? (json['discountPercentage'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString() ?? 'mixed',
      targetType: json['targetType']?.toString() ?? 'Student',
      isPremium: json['isPremium'] as bool? ?? false,
      hasAccess: json['hasAccess'] as bool? ?? false,
      totalQuestions: int.tryParse(json['totalQuestions']?.toString() ?? '') ?? (json['totalQuestions'] as num?)?.toInt() ?? 0,
      totalDurationMins: int.tryParse(json['totalDurationMins']?.toString() ?? '') ?? (json['totalDurationMins'] as num?)?.toInt() ?? 0,
      attempts: int.tryParse(json['attempts']?.toString() ?? '') ?? (json['attempts'] as num?)?.toInt() ?? 0,
      completions: int.tryParse(json['completions']?.toString() ?? '') ?? (json['completions'] as num?)?.toInt() ?? 0,
      avgScore: double.tryParse(json['avgScore']?.toString() ?? '') ?? (json['avgScore'] as num?)?.toDouble() ?? 0.0,
      passingScore: double.tryParse(json['passingScore']?.toString() ?? '') ?? (json['passingScore'] as num?)?.toDouble() ?? 0.0,
      targetCompanies: rawCompanies.map((e) => e.toString()).toList(),
      targetRoles: rawRoles.map((e) => e.toString()).toList(),
      industries: rawIndustries.map((e) => e.toString()).toList(),
      markingScheme: json['markingScheme'] != null 
          ? MarkingSchemeModel.fromJson(json['markingScheme'] as Map<String, dynamic>)
          : MarkingSchemeModel(correct: 4.0, wrong: 0.0, negative: 1.0),
      sections: parsedSections,
    );
  }
}
