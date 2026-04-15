class DashboardModel {
  final int xp;
  final int rank;
  final int xpProgress;
  final List<Enrollment> enrollments;
  final Map<String, dynamic>? student;
  final List<dynamic> drives; // 🔥 IMPORTANT

  DashboardModel({
    required this.xp,
    required this.rank,
    required this.xpProgress,
    required this.enrollments,
    required this.drives,
    this.student,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final enrollmentsData = json['enrollments'] as List? ?? [];

    return DashboardModel(
      xp: json['xp'] ?? 0,
      rank: json['rank'] ?? 0,
      xpProgress: json['xpProgress'] ?? 0,

      enrollments: enrollmentsData.map((e) => Enrollment.fromJson(e)).toList(),

      student: json['student'],
      drives: json['drives'] ?? [], // 🔥 FIX
    );
  }
}

class Enrollment {
  final String? id;
  final Course course;
  final int? completedModules;
  final int? progress;
  final DateTime? lastAccessed;

  Enrollment({
    this.id,
    required this.course,
    this.completedModules,
    this.progress,
    this.lastAccessed,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'],
      course: Course.fromJson(json['course']),
      completedModules: json['completedModules'],
      progress: json['progress'],
      lastAccessed: json['lastAccessed'] != null
          ? DateTime.parse(json['lastAccessed'])
          : null,
    );
  }

  double get progressPercentage {
    if (progress != null) {
      return (progress! / 100.0).clamp(0.0, 1.0);
    }
    if (completedModules != null && course.totalModules > 0) {
      return (completedModules! / course.totalModules).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  String get subtitleText {
    if (completedModules != null) {
      return '${completedModules}/${course.totalModules} modules';
    }
    return '${course.totalModules} modules';
  }
}

class Course {
  final String id;
  final String title;
  final String? thumbnail;
  final String? description;
  final int totalModules;
  final String? category;

  Course({
    required this.id,
    required this.title,
    this.thumbnail,
    this.description,
    required this.totalModules,
    this.category,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'],
      description: json['description'],
      totalModules: json['totalModules'] ?? 0,
      category: json['category'],
    );
  }
}
