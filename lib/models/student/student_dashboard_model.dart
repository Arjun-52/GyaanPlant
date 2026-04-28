import 'student_model.dart';

class LevelInfo {
  final int level;
  final int xp;
  final String title;
  final String color;

  const LevelInfo({
    required this.level,
    required this.xp,
    required this.title,
    required this.color,
  });

  factory LevelInfo.fromJson(Map<String, dynamic> json) => LevelInfo(
        level: json['level'] as int,
        xp: json['xp'] as int,
        title: json['title'] as String,
        color: json['color'] as String,
      );
}

class RecentPoint {
  final String id;
  final int points;
  final int xp;
  final String type;
  final String description;
  final String createdAt;

  const RecentPoint({
    required this.id,
    required this.points,
    required this.xp,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory RecentPoint.fromJson(Map<String, dynamic> json) => RecentPoint(
        id: json['_id'] as String,
        points: json['points'] as int,
        xp: json['xp'] as int,
        type: json['type'] as String,
        description: json['description'] as String,
        createdAt: json['createdAt'] as String,
      );
}

class StudentDashboard {
  final StudentModel student;
  final LevelInfo level;
  final LevelInfo nextLevel;
  final int xp;
  final int xpProgress;
  final int rank;
  final List<RecentPoint> recentPoints;

  const StudentDashboard({
    required this.student,
    required this.level,
    required this.nextLevel,
    required this.xp,
    required this.xpProgress,
    required this.rank,
    required this.recentPoints,
  });

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    return StudentDashboard(
      student: StudentModel.fromJson(json['student'] as Map<String, dynamic>),
      level: LevelInfo.fromJson(json['level'] as Map<String, dynamic>),
      nextLevel: LevelInfo.fromJson(json['nextLevel'] as Map<String, dynamic>),
      xp: json['xp'] as int? ?? 0,
      xpProgress: json['xpProgress'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      recentPoints: (json['recentPoints'] as List<dynamic>?)
              ?.map((e) => RecentPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
