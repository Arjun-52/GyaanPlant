import 'package:gyaanplant/core/utils/app_logger.dart';

class HodDashboardModel {
  static const _tag = 'HodDashboardModel';

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
      totalStudents: json["overview"]?["totalStudents"] ?? 0,
      departments: json["overview"]?["totalDepartments"] ?? 0,
      lmsAdoption: json["overview"]?["completionRate"] ?? 0,
      naacGrade: "N/A",
      departmentsData: _parseDepartments(json),
    );
  }

  static List<DeptModel> _parseDepartments(Map<String, dynamic> json) {
    final departmentStats = json["departmentStats"];

    if (departmentStats == null || departmentStats is! List || departmentStats.isEmpty) {
      return [];
    }

    final parsed = <DeptModel>[];
    for (final deptJson in departmentStats) {
      try {
        parsed.add(DeptModel.fromJson(deptJson));
      } catch (e) {
        AppLogger.warning(_tag, 'Failed to parse department: $e');
      }
    }
    return parsed;
  }
}

class DeptModel {
  final String name;
  final double value;

  DeptModel({required this.name, required this.value});

  factory DeptModel.fromJson(Map<String, dynamic> json) {
    final departmentName = json["departmentName"]?.toString().trim();
    final avgPoints = json["avgPoints"];

    final name = departmentName?.isNotEmpty == true ? departmentName! : "Unknown Department";
    final value = avgPoints != null ? ((avgPoints as num).toDouble() * 20) : 0.0;

    return DeptModel(name: name, value: value);
  }
}
