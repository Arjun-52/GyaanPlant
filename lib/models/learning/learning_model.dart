class LearningPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const LearningPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory LearningPagination.fromJson(Map<String, dynamic> json) =>
      LearningPagination(
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        limit: json['limit'] as int? ?? 20,
        totalPages: json['totalPages'] as int? ?? 0,
        hasNext: json['hasNext'] as bool? ?? false,
        hasPrev: json['hasPrev'] as bool? ?? false,
      );
}

class CourseModel {
  final String id;
  final String title;
  final String? description;
  final String? thumbnail;
  final String? category;
  final int totalModules;
  final String? level;
  final String? status;
  final String createdAt;
  final String updatedAt;

  const CourseModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    this.category,
    required this.totalModules,
    this.level,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json['_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        thumbnail: json['thumbnail'] as String?,
        category: json['category'] as String?,
        totalModules: json['totalModules'] as int? ?? 0,
        level: json['level'] as String?,
        status: json['status'] as String?,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}

class AssessmentModel {
  final String id;
  final String title;
  final String? description;
  final String? type;
  final int? totalQuestions;
  final int? duration;
  final String? difficulty;
  final String createdAt;
  final String updatedAt;

  const AssessmentModel({
    required this.id,
    required this.title,
    this.description,
    this.type,
    this.totalQuestions,
    this.duration,
    this.difficulty,
    required this.createdAt,
    required this.updatedAt,
  });

  // View compatibility alias
  String get skill => type ?? '';

  factory AssessmentModel.fromJson(Map<String, dynamic> json) => AssessmentModel(
        id: json['_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        type: json['type'] as String?,
        totalQuestions: json['totalQuestions'] as int?,
        duration: json['duration'] as int?,
        difficulty: json['difficulty'] as String?,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}
