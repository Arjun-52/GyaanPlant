class Student {
  final String id;
  final String name;
  final String email;
  final String branch;
  final String year;
  final int score; // Normalized score (0–100)
  final String status; // Mapped from readiness
  final String initials;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.branch,
    required this.year,
    required this.score,
    required this.status,
    required this.initials,
  });

  /// Parse API response to Student model
  factory Student.fromJson(Map<String, dynamic> json) {
    // 🔹 Extract nested user
    final user = json['user'] as Map<String, dynamic>? ?? {};

    final name = (user['name'] ?? '').toString().trim().isEmpty
        ? "Unknown Student"
        : user['name'];

    final email = (user['email'] ?? '').toString().isEmpty
        ? "No email"
        : user['email'];

    // 🔹 Branch handling (avoid showing ID)
    final branchRaw = json['branch'];

    final branchDisplay =
        (branchRaw == null || branchRaw.toString().length > 10)
        ? "N/A"
        : branchRaw.toString();

    // 🔹 Year formatting
    final yearNum = json['year'] as int? ?? 1;
    final yearDisplay = "$yearNum Year";

    // 🔹 Score calculation (BEST FIX)
    final score = _calculateScore(json);

    // 🔹 Status mapping
    final readiness = json['readiness'] as String?;
    final status = _mapReadinessToStatus(readiness);

    // 🔹 Initials
    final initials = _getInitials(name);

    return Student(
      id: json['_id']?.toString() ?? '',
      name: name,
      email: email,
      branch: branchDisplay,
      year: yearDisplay,
      score: score,
      status: status,
      initials: initials,
    );
  }

  /// 🔥 SMART SCORE CALCULATION
  static int _calculateScore(Map<String, dynamic> json) {
    final profileStrength = json['profileStrength'] ?? 0;
    final xp = json['xp'] ?? 0;
    final totalPoints = json['totalPoints'] ?? 0;

    // Priority: profileStrength > xp > totalPoints
    if (profileStrength > 0) {
      return profileStrength;
    }

    if (xp > 0) {
      // Normalize XP → score (0–100)
      return (xp * 3).clamp(0, 100);
    }

    if (totalPoints > 0) {
      return (totalPoints * 2).clamp(0, 100);
    }

    return 0;
  }

  /// 🔹 Readiness → UI status
  static String _mapReadinessToStatus(String? readiness) {
    switch (readiness?.toLowerCase()) {
      case "high":
        return "MNC Ready";
      case "medium":
        return "Average";
      case "low":
        return "At Risk";
      default:
        return "Unknown";
    }
  }

  /// 🔹 Generate initials
  static String _getInitials(String name) {
    if (name.isEmpty) return "?";

    final parts = name.trim().split(" ");
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// 🔹 Debug helper
  @override
  String toString() {
    return 'Student(name: $name, branch: $branch, score: $score, status: $status)';
  }
}
