class RoleModel {
  final String title;
  final String subtitle;
  final String icon;

  RoleModel({required this.title, required this.subtitle, required this.icon});
}

class RoleViewModel {
  List<RoleModel> roles = [
    RoleModel(
      title: "Student",
      subtitle: "Learn, practice, get placed — full student journey",
      icon: "🎓",
    ),
    RoleModel(
      title: "TPO — Training & Placement Officer",
      subtitle: "Manage drives, track readiness, generate NAAC reports",
      icon: "🏫",
    ),
    RoleModel(
      title: "HOD / Principal",
      subtitle: "Department analytics, syllabus mapping, accreditation",
      icon: "📐",
    ),
    RoleModel(
      title: "Admin / CEO",
      subtitle: "Platform KPIs, MOU pipeline, revenue & growth",
      icon: "⚡",
    ),
    RoleModel(
      title: "Alumni Mentor",
      subtitle: "Manage bookings, sessions, earnings dashboard",
      icon: "🧑‍🏫",
    ),
  ];
}
