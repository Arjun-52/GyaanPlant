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
    print("🔍 MODEL PARSING JSON: $json");

    return HodDashboardModel(
      totalStudents: json["overview"]?["totalStudents"] ?? 0,
      departments: json["overview"]?["totalDepartments"] ?? 0,
      lmsAdoption: json["overview"]?["completionRate"] ?? 0,
      naacGrade: "N/A",

      departmentsData: (json["departmentStats"] as List? ?? [])
          .map((e) => DeptModel.fromJson(e))
          .toList(),
    );
  }
}

class DeptModel {
  final String name;
  final double value;

  DeptModel({required this.name, required this.value});

  factory DeptModel.fromJson(Map<String, dynamic> json) {
    print("🔍 DEPT MODEL PARSING: $json");
    return DeptModel(
      name: json["departmentName"]?.toString().trim() ?? "Unknown",
      value: ((json["avgPoints"] ?? 0) as num).toDouble() * 20,
    );
  }
}
