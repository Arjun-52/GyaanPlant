/// Model for student data from API response
class StudentModel {
  final String id;
  final String name;
  final String email;
  final String college;
  final String branch;
  final String? profileImage;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.college,
    required this.branch,
    this.profileImage,
  });

  /// Create StudentModel from JSON (API response)
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      college: json['college']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      profileImage: json['profile_image'],
    );
  }

  /// Convert StudentModel to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'college': college,
      'branch': branch,
      if (profileImage != null) 'profile_image': profileImage,
    };
  }
}
