class JobModel {
  final String id;
  final String companyName;
  final String role;
  final String? driveDate;

  JobModel({
    required this.id,
    required this.companyName,
    required this.role,
    this.driveDate,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['_id'] ?? '',
      companyName: json['companyName'] ?? '',
      role: json['role'] ?? '',
      driveDate: json['driveDate'],
    );
  }
}
