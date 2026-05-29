/// Model for the course progress API response.
///
/// Parses the response from `PUT /api/v1/learning/{courseId}/progress`:
/// ```json
/// {
///   "success": true,
///   "data": { ... },
///   "rewards": { "pointsEarned": 0, "xpEarned": 0 }
/// }
class CourseProgressModel {
  final String id;
  final String course;
  final String user;
  final String? student;
  final List<String> completedLectures;
  final int progress;
  final String status;
  final List<dynamic> quizScores;
  final int timeSpentMins;
  final int pointsEarned;
  final int xpEarned;
  final DateTime? lastAccessed;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProgressRewards rewards;

  const CourseProgressModel({
    required this.id,
    required this.course,
    required this.user,
    this.student,
    required this.completedLectures,
    required this.progress,
    required this.status,
    required this.quizScores,
    required this.timeSpentMins,
    required this.pointsEarned,
    required this.xpEarned,
    this.lastAccessed,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    required this.rewards,
  });

  /// Parse from the full API response envelope (contains `data` + `rewards`).
  factory CourseProgressModel.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final rewardsJson = json['rewards'] as Map<String, dynamic>? ?? {};

    return CourseProgressModel(
      id: data['_id'] as String? ?? data['id'] as String? ?? '',
      course: data['course'] as String? ?? '',
      user: data['user'] as String? ?? '',
      student: data['student'] as String?,
      completedLectures: (data['completedLectures'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      progress: _safeInt(data['progress']),
      status: data['status'] as String? ?? 'in-progress',
      quizScores: data['quizScores'] as List<dynamic>? ?? [],
      timeSpentMins: _safeInt(data['timeSpentMins']),
      pointsEarned: _safeInt(data['pointsEarned']),
      xpEarned: _safeInt(data['xpEarned']),
      lastAccessed: _safeDateTime(data['lastAccessed']),
      completedAt: _safeDateTime(data['completedAt']),
      createdAt: _safeDateTime(data['createdAt']),
      updatedAt: _safeDateTime(data['updatedAt']),
      rewards: ProgressRewards.fromJson(rewardsJson),
    );
  }

  bool get isCompleted => status == 'completed' || progress >= 100;

  static int _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

/// Rewards section nested in the progress API response.
class ProgressRewards {
  final int pointsEarned;
  final int xpEarned;

  const ProgressRewards({
    required this.pointsEarned,
    required this.xpEarned,
  });

  factory ProgressRewards.fromJson(Map<String, dynamic> json) {
    return ProgressRewards(
      pointsEarned: _safeInt(json['pointsEarned']),
      xpEarned: _safeInt(json['xpEarned']),
    );
  }

  bool get hasRewards => pointsEarned > 0 || xpEarned > 0;

  static int _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
