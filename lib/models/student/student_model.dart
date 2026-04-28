class StudentUser {
  final String id;
  final String name;
  final String email;
  final String? avatar;

  const StudentUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory StudentUser.fromJson(Map<String, dynamic> json) => StudentUser(
        id: json['_id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        avatar: json['avatar'] as String?,
      );
}

class StudentCollege {
  final String id;
  final String name;
  final String? city;

  const StudentCollege({required this.id, required this.name, this.city});

  factory StudentCollege.fromJson(Map<String, dynamic> json) => StudentCollege(
        id: json['_id'] as String,
        name: json['name'] as String,
        city: json['city'] as String?,
      );
}

class StudentModel {
  final String id;
  final StudentUser? user;
  final StudentCollege? college;
  final String? branch;
  final int year;
  final double cgpa;
  final String? careerPath;
  final List<String> skills;
  final double mockScore;
  final int testsCompleted;
  final String readiness;
  final int profileStrength;
  final int totalPoints;
  final int weeklyPoints;
  final int monthlyPoints;
  final int level;
  final int xp;
  final int streakDays;
  final List<String> badges;
  final int rank;
  final String createdAt;
  final String updatedAt;
  final String? lastActivityDate;

  const StudentModel({
    required this.id,
    this.user,
    this.college,
    this.branch,
    required this.year,
    required this.cgpa,
    this.careerPath,
    required this.skills,
    required this.mockScore,
    required this.testsCompleted,
    required this.readiness,
    required this.profileStrength,
    required this.totalPoints,
    required this.weeklyPoints,
    required this.monthlyPoints,
    required this.level,
    required this.xp,
    required this.streakDays,
    required this.badges,
    required this.rank,
    required this.createdAt,
    required this.updatedAt,
    this.lastActivityDate,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'];
    final collegeRaw = json['college'];

    return StudentModel(
      id: json['_id'] as String,
      user: userRaw is Map<String, dynamic>
          ? StudentUser.fromJson(userRaw)
          : null,
      college: collegeRaw is Map<String, dynamic>
          ? StudentCollege.fromJson(collegeRaw)
          : null,
      branch: json['branch'] as String?,
      year: json['year'] as int? ?? 1,
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0.0,
      careerPath: json['career_path'] as String?,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      mockScore: (json['mockScore'] as num?)?.toDouble() ?? 0.0,
      testsCompleted: json['testsCompleted'] as int? ?? 0,
      readiness: json['readiness'] as String? ?? 'Low',
      profileStrength: json['profileStrength'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      weeklyPoints: json['weeklyPoints'] as int? ?? 0,
      monthlyPoints: json['monthlyPoints'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rank: json['rank'] as int? ?? 0,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      lastActivityDate: json['lastActivityDate'] as String?,
    );
  }
}
