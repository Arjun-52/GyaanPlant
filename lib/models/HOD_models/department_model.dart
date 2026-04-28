class Department {
  final String name;
  final int students;
  final int readiness;
  final String hod;
  final String icon;

  Department({
    required this.name,
    required this.students,
    required this.readiness,
    required this.hod,
    required this.icon,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    print("🔍 DEPT MODEL PARSING JSON: $json");

    // Handle current API structure (college object)
    if (json.containsKey("college")) {
      final college = json["college"] as Map<String, dynamic>? ?? {};
      final stats = college["stats"] as Map<String, dynamic>? ?? {};

      return Department(
        name: college["name"]?.toString() ?? "Unknown College",
        students: stats["totalStudents"] ?? 0,
        readiness: stats["placementRate"] ?? 0,
        hod: "Principal", // Default since not provided
        icon: "🏫", // College icon
      );
    }

    // Handle expected department structure (for future)
    return Department(
      name: json["name"]?.toString() ?? "Unknown",
      students: json["students"] ?? 0,
      readiness: json["readiness"] ?? 0,
      hod: json["hod"]?.toString() ?? "Unknown",
      icon: json["icon"]?.toString() ?? "📚",
    );
  }
}
