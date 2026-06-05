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
    print("🔬 [AuthResponse.fromJson] Raw Response JSON: $json");
    
    // Check if the response is nested under a 'data' object
    Map<String, dynamic> data = json;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
      print("🔬 [AuthResponse.fromJson] Found nested 'data' map: $data");
    } else {
      print("🔬 [AuthResponse.fromJson] Using direct JSON map (not nested under 'data')");
    }

    // Try extracting the token from multiple common keys
    final token = data['accessToken'] as String? ?? data['token'] as String?;
    print("🔬 [AuthResponse.fromJson] Extracted Token: $token");
    if (token == null || token.isEmpty) {
      throw FormatException("Token missing in authentication response");
    }

    final expiresIn = data['expiresIn'] as int? ?? 900;

    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw FormatException("User field is missing in authentication response data");
    }

    final user = AuthUser.fromJson(userJson);
    print("🔬 [AuthResponse.fromJson] Parsed: ${user.name} (${user.role})");

    return AuthResponse(
      accessToken: token,
      expiresIn: expiresIn,
      user: user,
    );
  }
}
