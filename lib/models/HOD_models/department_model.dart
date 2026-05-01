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
    print("🔍 DEPT MODEL PARSING JSON: $json");
    print("🔍 JSON KEYS: ${json.keys.toList()}");

    // Parse department name
    final deptName = json["name"]?.toString() ?? "Unknown Department";
    print("🔍 DEPARTMENT NAME: $deptName");

    // Parse department code
    final deptCode = json["code"]?.toString();
    print("🔍 DEPARTMENT CODE: $deptCode");

    // Parse department head
    Head? deptHead;
    if (json.containsKey("head") && json["head"] != null) {
      if (json["head"] is Map<String, dynamic>) {
        deptHead = Head.fromJson(json["head"] as Map<String, dynamic>);
        print("🔍 DEPARTMENT HEAD: ${deptHead.name}");
      } else if (json["head"] is String) {
        deptHead = Head(name: json["head"] as String);
        print("🔍 DEPARTMENT HEAD (STRING): ${deptHead.name}");
      }
    } else {
      print("🔍 NO DEPARTMENT HEAD FOUND");
    }

    // Parse college
    College? deptCollege;
    if (json.containsKey("college") && json["college"] != null) {
      if (json["college"] is Map<String, dynamic>) {
        deptCollege = College.fromJson(json["college"] as Map<String, dynamic>);
        print("🔍 DEPARTMENT COLLEGE: ${deptCollege.name}");
      } else {
        print("🔍 COLLEGE IS NOT A MAP: ${json["college"].runtimeType}");
      }
    } else {
      print("🔍 NO COLLEGE FOUND");
    }

    // Parse icon (fallback to default)
    final deptIcon = json["icon"]?.toString() ?? "📚";
    print("🔍 DEPARTMENT ICON: $deptIcon");

    // Log final department info
    print(
      "✅ DEPARTMENT CREATED: $deptName (${deptCode ?? 'No Code'}) - HOD: ${deptHead?.name ?? 'None'} - College: ${deptCollege?.name ?? 'None'}",
    );

    return Department(
      name: deptName,
      code: deptCode,
      head: deptHead,
      college: deptCollege,
      icon: deptIcon,
    );
  }
}
