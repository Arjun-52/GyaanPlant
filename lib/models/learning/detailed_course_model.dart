class DetailedCourseModel {
  final String id;
  final String title;
  final String? thumbnail;
  final String? duration;
  final int totalModules;
  final int pointsReward;
  final int xpReward;
  final int passingScore;
  final List<String> targetAudience;
  final String? category;
  final int enrolled;
  final int price;
  final List<DetailedModule> modules;
  final DetailedEnrollment? enrollment;
  final bool hasAccess;

  DetailedCourseModel({
    required this.id,
    required this.title,
    this.thumbnail,
    this.duration,
    required this.totalModules,
    required this.pointsReward,
    required this.xpReward,
    required this.passingScore,
    required this.targetAudience,
    this.category,
    required this.enrolled,
    required this.price,
    required this.modules,
    this.enrollment,
    required this.hasAccess,
  });

  factory DetailedCourseModel.fromJson(Map<String, dynamic> json) {
    return DetailedCourseModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      duration: json['duration'] as String? ?? '0h 0m',
      totalModules: json['totalModules'] as int? ?? 0,
      pointsReward: json['pointsReward'] as int? ?? 0,
      xpReward: json['xpReward'] as int? ?? 0,
      passingScore: json['passingScore'] as int? ?? 0,
      targetAudience: (json['targetAudience'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: json['category'] as String?,
      enrolled: json['enrolled'] as int? ?? 0,
      price: json['price'] as int? ?? 0,
      modules: (json['modules'] as List<dynamic>?)
              ?.map((e) => DetailedModule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      enrollment: json['enrollment'] != null
          ? DetailedEnrollment.fromJson(json['enrollment'] as Map<String, dynamic>)
          : null,
      hasAccess: json['hasAccess'] as bool? ?? false,
    );
  }
}

class DetailedModule {
  final String title;
  final List<DetailedLecture> lectures;

  DetailedModule({required this.title, required this.lectures});

  factory DetailedModule.fromJson(Map<String, dynamic> json) {
    return DetailedModule(
      title: json['title'] as String? ?? '',
      lectures: (json['lectures'] as List<dynamic>?)
              ?.map((e) => DetailedLecture.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DetailedLecture {
  final String title;
  final int durationMins;
  final int points;
  final int xp;

  DetailedLecture({
    required this.title,
    required this.durationMins,
    required this.points,
    required this.xp,
  });

  factory DetailedLecture.fromJson(Map<String, dynamic> json) {
    return DetailedLecture(
      title: json['title'] as String? ?? '',
      durationMins: json['durationMins'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      xp: json['xp'] as int? ?? 0,
    );
  }
}

class DetailedEnrollment {
  final String status;
  final int progress;

  DetailedEnrollment({required this.status, required this.progress});

  factory DetailedEnrollment.fromJson(Map<String, dynamic> json) {
    return DetailedEnrollment(
      status: json['status'] as String? ?? '',
      progress: json['progress'] as int? ?? 0,
    );
  }
}
