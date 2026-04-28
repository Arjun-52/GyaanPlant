import 'auth_user_model.dart';

/// Returned by login and register:
/// { "success": true, "accessToken": "...", "expiresIn": 900, "user": { ... } }
class AuthResponse {
  final String accessToken;
  final int expiresIn;
  final AuthUser user;

  const AuthResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      expiresIn: json['expiresIn'] as int? ?? 900,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
