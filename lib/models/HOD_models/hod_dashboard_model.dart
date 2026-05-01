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

      departmentsData: _parseDepartments(json),
    );
  }

  static List<DeptModel> _parseDepartments(Map<String, dynamic> json) {
    print("🔍 PARSING DEPARTMENTS FROM JSON KEYS: ${json.keys.toList()}");

    final departmentStats = json["departmentStats"];
    print("🔍 DEPARTMENT STATS RAW: $departmentStats");
    print("🔍 DEPARTMENT STATS TYPE: ${departmentStats.runtimeType}");

    if (departmentStats == null) {
      print("❌ DEPARTMENT STATS IS NULL - RETURNING EMPTY LIST");
      return [];
    }

    if (departmentStats is! List) {
      print(
        "❌ DEPARTMENT STATS IS NOT A LIST - TYPE: ${departmentStats.runtimeType}",
      );
      return [];
    }

    if (departmentStats.isEmpty) {
      print("❌ DEPARTMENT STATS LIST IS EMPTY - RETURNING EMPTY LIST");
      return [];
    }

    print("✅ DEPARTMENT STATS LIST HAS ${departmentStats.length} ITEMS");

    final parsed = <DeptModel>[];
    for (int i = 0; i < departmentStats.length; i++) {
      final deptJson = departmentStats[i];
      print("🔍 PARSING DEPARTMENT $i: $deptJson");

      try {
        final dept = DeptModel.fromJson(deptJson);
        print("✅ DEPARTMENT $i PARSED: ${dept.name} = ${dept.value}%");
        parsed.add(dept);
      } catch (e) {
        print("❌ ERROR PARSING DEPARTMENT $i: $e");
      }
    }

    print("✅ FINAL RESULT: ${parsed.length} DEPARTMENTS PARSED");
    return parsed;
  }
}

class DeptModel {
  final String name;
  final double value;

  DeptModel({required this.name, required this.value});

  factory DeptModel.fromJson(Map<String, dynamic> json) {
    print("🔍 DEPT MODEL PARSING: $json");
    print("🔍 DEPT JSON KEYS: ${json.keys.toList()}");

    final departmentName = json["departmentName"]?.toString().trim();
    print("🔍 DEPARTMENT NAME: $departmentName");

    final avgPoints = json["avgPoints"];
    print("🔍 AVG POINTS: $avgPoints (TYPE: ${avgPoints.runtimeType})");

    final name = departmentName?.isNotEmpty == true
        ? departmentName!
        : "Unknown Department";
    final value = avgPoints != null
        ? ((avgPoints as num).toDouble() * 20)
        : 0.0;

    print("✅ DEPT MODEL CREATED: $name = ${value.toStringAsFixed(1)}%");

    return DeptModel(name: name, value: value);
  }
}
