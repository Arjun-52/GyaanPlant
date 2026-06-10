enum UserRole { student, mentor, hod, tpo }

class AuthResult {
  final UserRole role;
  final String? token;
  final String? email;
  final String? name;
  final String? googleId;
  final String? photoUrl;

  AuthResult({
    required this.role,
    this.token,
    this.email,
    this.name,
    this.googleId,
    this.photoUrl,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] as String?)?.toLowerCase() ?? 'student';
    UserRole role;
    switch (roleStr) {
      case 'mentor':
        role = UserRole.mentor;
        break;
      case 'hod':
        role = UserRole.hod;
        break;
      case 'tpo':
        role = UserRole.tpo;
        break;
      default:
        role = UserRole.student;
    }
    return AuthResult(
      role: role,
      token: json['token'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      googleId: json['googleId'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
