class JobModel {
  final String id;
  final String company;
  final String role;
  final String location;
  final String salary;
  final int match;
  final List<String> skills;
  final bool isNew;

  JobModel({
    required this.id,
    required this.company,
    required this.role,
    required this.location,
    required this.salary,
    required this.match,
    required this.skills,
    required this.isNew,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['_id'] ?? '',
      company: json['companyName'] ?? '',
      role: json['role'] ?? '',
      location: json['location'] ?? 'Not specified',
      salary: json['salary'] ?? '',
      match: json['matchPercentage'] ?? 0,
      skills: (json['skills'] is List) ? List<String>.from(json['skills']) : [],
      isNew: json['isNew'] ?? false,
    );
  }
}
