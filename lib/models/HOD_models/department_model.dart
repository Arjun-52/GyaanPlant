class Head {
  final String? name;

  Head({this.name});

  factory Head.fromJson(Map<String, dynamic> json) {
    return Head(name: json["name"]?.toString());
  }
}

class College {
  final String? name;

  College({this.name});

  factory College.fromJson(Map<String, dynamic> json) {
    return College(name: json["name"]?.toString());
  }
}

class Department {
  final String name;
  final String? code;
  final Head? head;
  final College? college;
  final String icon;

  Department({
    required this.name,
    this.code,
    this.head,
    this.college,
    required this.icon,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    final deptName = json["name"]?.toString() ?? "Unknown Department";
    final deptCode = json["code"]?.toString();
    final deptIcon = json["icon"]?.toString() ?? "📚";

    Head? deptHead;
    if (json["head"] != null) {
      if (json["head"] is Map<String, dynamic>) {
        deptHead = Head.fromJson(json["head"] as Map<String, dynamic>);
      } else if (json["head"] is String) {
        deptHead = Head(name: json["head"] as String);
      }
    }

    College? deptCollege;
    if (json["college"] is Map<String, dynamic>) {
      deptCollege = College.fromJson(json["college"] as Map<String, dynamic>);
    }

    return Department(
      name: deptName,
      code: deptCode,
      head: deptHead,
      college: deptCollege,
      icon: deptIcon,
    );
  }
}
