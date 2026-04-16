class SettingsModel {
  final String name;
  final String role;
  final String college;
  final String initials;

  SettingsModel({
    required this.name,
    required this.role,
    required this.college,
    required this.initials,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      college: json['college'] ?? '',
      initials: json['initials'] ?? '',
    );
  }
}
