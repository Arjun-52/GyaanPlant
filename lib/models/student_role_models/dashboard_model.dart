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
      xp: _parseToInt(json['xp']),
      rank: _parseToInt(json['rank']),
      xpProgress: _parseToInt(json['xpProgress']),

      enrollments: enrollmentsData
          .where((e) => e != null)
          .map((e) => Enrollment.fromJson(e))
          .toList(),

      student: json['student'],
      drives: json['drives'] ?? [], //  FIX
    );
  }

  /// Helper function to parse API response that might send arrays instead of integers
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is List) {
      // Take the first item if array is not empty
      if (value.isNotEmpty) {
        final firstItem = value.first;
        if (firstItem is int) return firstItem;
        if (firstItem is String) {
          return int.tryParse(firstItem) ?? 0;
        }
      }
      return 0;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
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
    print("🔧 PARSING ENROLLMENT: $json");

    final courseData = json['course'];
    print("🔧 COURSE DATA: $courseData");

    final String courseIdFromEnrollment = (json['courseId'] ?? json['course_id'] ?? '').toString();

    Course course;
    if (courseData is Map<String, dynamic>) {
      course = Course.fromJson(courseData);
      if (course.id.isEmpty && courseIdFromEnrollment.isNotEmpty) {
        course = Course(
          id: courseIdFromEnrollment,
          title: course.title,
          thumbnail: course.thumbnail,
          description: course.description,
          totalModules: course.totalModules,
          category: course.category,
        );
      }
    } else if (courseData is String) {
      course = Course(
        id: courseData,
        title: 'Unknown',
        totalModules: 0,
      );
    } else {
      course = Course(
        id: courseIdFromEnrollment,
        title: 'Unknown',
        totalModules: 0,
      );
    }

    print("🔧 PARSED COURSE: ${course.title} (ID: ${course.id})");

    final enrollment = Enrollment(
      id: json['_id'] ?? '',
      course: course,
      completedModules: DashboardModel._parseToInt(json['completedModules']),
      progress: DashboardModel._parseToInt(json['progress']),
      lastAccessed: json['lastAccessed'] != null
          ? DateTime.parse(json['lastAccessed'])
          : null,
    );

    print("🔧 CREATED ENROLLMENT: ${enrollment.course.title}");
    return enrollment;
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
      return '$completedModules/${course.totalModules} modules';
    }
    return '${course.totalModules} modules';
  }

  /// Create an empty Enrollment instance
  factory Enrollment.empty() {
    return Enrollment(
      course: Course(id: '', title: '', totalModules: 0),
    );
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
    print("🔧 PARSING COURSE: $json");

    final course = Course(
      id: json['_id'] ?? json['id'] ?? json['courseId'] ?? json['course_id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'],
      description: json['description'],
      totalModules: DashboardModel._parseToInt(json['totalModules']),
      category: json['category'],
    );

    print(
      "🔧 CREATED COURSE: ${course.title} (ID: ${course.id}, ${course.totalModules} modules)",
    );
    return course;
  }
}
