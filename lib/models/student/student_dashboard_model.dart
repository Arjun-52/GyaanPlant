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
        level: json['level'] as int? ?? 1,
        xp: json['xp'] as int? ?? 0,
        title: json['title'] as String? ?? 'Novice',
        color: json['color'] as String? ?? 'green',
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
        id: json['_id'] as String? ?? '',
        points: json['points'] as int? ?? 0,
        xp: json['xp'] as int? ?? 0,
        type: json['type'] as String? ?? '',
        description: json['description'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
      );
}

class StudentDashboard {
  final StudentModel? student;
  final LevelInfo? level;
  final LevelInfo? nextLevel;
  final int xp;
  final int xpProgress;
  final int rank;
  final List<RecentPoint> recentPoints;
  final List<dynamic> drives;

  const StudentDashboard({
    this.student,
    this.level,
    this.nextLevel,
    required this.xp,
    required this.xpProgress,
    required this.rank,
    required this.recentPoints,
    required this.drives,
  });

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    print("🧩 [StudentDashboard.fromJson] ===== STARTING PARSE =====");
    print("🧩 [StudentDashboard.fromJson] Raw json map: $json");
    print("🧩 [StudentDashboard.fromJson] Keys in json: ${json.keys.toList()}");
    
    try {
      final studentData = json['student'];
      print("🧩 [StudentDashboard.fromJson] student field: $studentData (type: ${studentData.runtimeType})");
      
      final levelData = json['level'];
      print("🧩 [StudentDashboard.fromJson] level field: $levelData (type: ${levelData.runtimeType})");
      
      final nextLevelData = json['nextLevel'];
      print("🧩 [StudentDashboard.fromJson] nextLevel field: $nextLevelData (type: ${nextLevelData.runtimeType})");
      
      final xpValue = json['xp'];
      print("🧩 [StudentDashboard.fromJson] xp field: $xpValue (type: ${xpValue.runtimeType})");
      
      final xpProgressValue = json['xpProgress'];
      print("🧩 [StudentDashboard.fromJson] xpProgress field: $xpProgressValue (type: ${xpProgressValue.runtimeType})");
      
      final rankValue = json['rank'];
      print("🧩 [StudentDashboard.fromJson] rank field: $rankValue (type: ${rankValue.runtimeType})");
      
      final recentPointsData = json['recentPoints'];
      print("🧩 [StudentDashboard.fromJson] recentPoints field: $recentPointsData (type: ${recentPointsData.runtimeType})");
      
      print("🧩 [StudentDashboard.fromJson] Special fields: profileMissing=${json['profileMissing']}, roleIncomplete=${json['roleIncomplete']}");

      final parsedDashboard = StudentDashboard(
        student: studentData is Map<String, dynamic>
            ? StudentModel.fromJson(studentData)
            : null,
        level: levelData is Map<String, dynamic>
            ? LevelInfo.fromJson(levelData)
            : null,
        nextLevel: nextLevelData is Map<String, dynamic>
            ? LevelInfo.fromJson(nextLevelData)
            : null,
        xp: xpValue is int ? xpValue : (xpValue is String ? int.tryParse(xpValue) ?? 0 : 0),
        xpProgress: xpProgressValue is int ? xpProgressValue : (xpProgressValue is String ? int.tryParse(xpProgressValue) ?? 0 : 0),
        rank: rankValue is int ? rankValue : (rankValue is String ? int.tryParse(rankValue) ?? 0 : 0),
        recentPoints: recentPointsData is List<dynamic>
                ? recentPointsData
                    .map((e) {
                      print("🧩 [StudentDashboard.fromJson] Parsing recentPoint: $e");
                      return RecentPoint.fromJson(e as Map<String, dynamic>);
                    })
                    .toList()
                : [],
        drives: json['drives'] as List<dynamic>? ?? [],
      );
      print("🧩 [StudentDashboard.fromJson] ✅ Parsing completed successfully");
      print("🧩 [StudentDashboard.fromJson] Result: xp=${parsedDashboard.xp}, rank=${parsedDashboard.rank}, student=${parsedDashboard.student != null ? 'present' : 'null'}");
      return parsedDashboard;
    } catch (e, st) {
      print("🧩 [StudentDashboard.fromJson] ❌ EXCEPTION DURING PARSE: $e");
      print(st);
      rethrow;
    }
  }
}

