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
    return Department(
      name: json["name"]?.toString() ?? "Unknown",
      students: json["students"] ?? 0,
      readiness: json["readiness"] ?? 0,
      hod: json["hod"]?.toString() ?? "Unknown",
      icon: json["icon"]?.toString() ?? "📚",
    );
  }
}
