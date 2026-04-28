import '../models/auth/auth_response_model.dart';
import '../models/auth/auth_user_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class AuthRepository {
  final NetworkAPIManager _api;

  AuthRepository(this._api);

  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) {
    return _api.post<AuthResponse>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AuthResponse>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return _api.post<AuthResponse>(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> logout() {
    return _api.post<void>(ApiEndpoints.logout);
  }

  Future<ApiResponse<AuthUser>> getCurrentUser() {
    return _api.get<AuthUser>(
      ApiEndpoints.me,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        // GET /me wraps the user under "data"
        final userData = map['data'] as Map<String, dynamic>? ?? map;
        return AuthUser.fromJson(userData);
      },
    );
  }

  Future<ApiResponse<void>> forgotPassword({required String email}) {
    return _api.post<void>(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return _api.post<void>(
      ApiEndpoints.resetPassword,
      data: {'token': token, 'password': newPassword},
    );
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _api.post<void>(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
