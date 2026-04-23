class HodDashboardModel {
  final int totalStudents;
  final int departments;
  final int lmsAdoption;
  final String naacGrade;
  final List<DeptModel> departmentsData;

  HodDashboardModel({
    required this.totalStudents,
    required this.departments,
    required this.lmsAdoption,
    required this.naacGrade,
    required this.departmentsData,
  });

  factory HodDashboardModel.fromJson(Map<String, dynamic> json) {
    return HodDashboardModel(
      totalStudents: json["totalStudents"] ?? 0,
      departments: json["departments"] ?? 0,
      lmsAdoption: json["lmsAdoption"] ?? 0,
      naacGrade: json["naacGrade"]?.toString() ?? "N/A", // 🔥 FIX
      departmentsData: (json["deptStats"] as List? ?? [])
          .map((e) => DeptModel.fromJson(e))
          .toList(),
    );
  }
}

class DeptModel {
  final String name;
  final int value;

  DeptModel({required this.name, required this.value});

  factory DeptModel.fromJson(Map<String, dynamic> json) {
    return DeptModel(
      name: json["name"]?.toString() ?? "Unknown",
      value: json["value"] ?? 0,
    );
  }
}
