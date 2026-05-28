class Student {
  final String id;
  final String name;
  final String email;
  final String branch;
  final String branchId;
  final String year;
  final int score; // Normalized score (0–100)
  final String status; // Mapped from readiness
  final String initials;
  final String rollNo;
  final double cgpa;
  final String careerPath;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.branch,
    required this.branchId,
    required this.year,
    required this.score,
    required this.status,
    required this.initials,
    required this.rollNo,
    required this.cgpa,
    required this.careerPath,
  });

  /// Parse API response to Student model
  factory Student.fromJson(Map<String, dynamic> json) {
    //  Extract nested user safely
    final userRaw = json['user'];
    final Map<String, dynamic> user = userRaw is Map<String, dynamic> ? userRaw : {};

    final name = (user['name'] ?? json['name'] ?? '').toString().trim().isEmpty
        ? "Unknown Student"
        : (user['name'] ?? json['name']).toString();

    final email = (user['email'] ?? json['email'] ?? '').toString().trim().isEmpty
        ? "No email"
        : (user['email'] ?? json['email']).toString();

    //  Branch handling
    final branchRaw = json['branch'];
    String branchDisplay = "N/A";
    String branchId = "";

    if (branchRaw != null) {
      if (branchRaw is Map<String, dynamic>) {
        branchDisplay = branchRaw['name']?.toString() ?? "N/A";
        branchId = branchRaw['_id']?.toString() ?? branchRaw['id']?.toString() ?? "";
      } else if (branchRaw is String) {
        branchId = branchRaw;
        branchDisplay = branchRaw.length > 10 ? "N/A" : branchRaw;
      }
    }

    //  Year formatting safely
    final yearRaw = json['year'];
    int yearNum = 1;
    if (yearRaw is int) {
      yearNum = yearRaw;
    } else if (yearRaw is num) {
      yearNum = yearRaw.toInt();
    } else if (yearRaw is String) {
      yearNum = int.tryParse(yearRaw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    }
    final yearDisplay = "Year $yearNum";

    //  Score calculation (BEST FIX)
    final score = _calculateScore(json);

    //  Status mapping
    final readiness = json['readiness']?.toString();
    final status = _mapReadinessToStatus(readiness);

    //  Initials
    final initials = _getInitials(name);

    // Rich Fields parsing & generation
    final rollNo = json['rollNo']?.toString() ?? json['rollNumber']?.toString() ?? _generateMockRollNo(json);
    
    final cgpaRaw = json['cgpa'];
    double cgpa = 0.0;
    if (cgpaRaw is num) {
      cgpa = cgpaRaw.toDouble();
    } else if (cgpaRaw is String) {
      cgpa = double.tryParse(cgpaRaw) ?? 0.0;
    }
    if (cgpa <= 0.0) {
      cgpa = _generateMockCgpa(score);
    }
    
    final careerPath = json['careerPath']?.toString() ?? json['career_path']?.toString() ?? "Software Engineer";

    return Student(
      id: json['_id']?.toString() ?? '',
      name: name,
      email: email,
      branch: branchDisplay,
      branchId: branchId,
      year: yearDisplay,
      score: score,
      status: status,
      initials: initials,
      rollNo: rollNo,
      cgpa: cgpa,
      careerPath: careerPath,
    );
  }

  static String _generateMockRollNo(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? '';
    final suffix = id.length >= 4 ? id.substring(id.length - 4).toUpperCase() : '101';
    final branch = json['branch']?.toString() ?? 'CSE';
    final branchCode = branch.contains('CS') || branch.contains('CSE') ? 'CS' : 'EC';
    return "21$branchCode$suffix";
  }

  static double _generateMockCgpa(int score) {
    if (score == 0) return 7.5;
    final derived = 6.0 + (score / 100) * 3.8;
    return double.parse(derived.toStringAsFixed(1));
  }

  ///  SMART SCORE CALCULATION
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

  ///  Readiness → UI status
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

  /// Generate initials
  static String _getInitials(String name) {
    if (name.isEmpty) return "?";

    final parts = name.trim().split(" ");
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Debug helper
  @override
  String toString() {
    return 'Student(name: $name, branch: $branch, score: $score, status: $status)';
  }
}
