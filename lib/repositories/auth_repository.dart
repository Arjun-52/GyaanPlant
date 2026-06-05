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
      data: {'name': name, 'email': email, 'password': password, 'role': role},
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> logout() {
    return _api.post<void>(ApiEndpoints.logout);
  }

  Future<ApiResponse<AuthUser>> getCurrentUser() async {
    try {
      print("🔥 GETTING CURRENT USER FROM /api/v1/auth/me");

      final response = await _api.get<Map<String, dynamic>>(ApiEndpoints.me);

      // 🔥 DEBUG RAW RESPONSE
      print("🔥 RAW /me RESPONSE: ${response.data}");
      print("🔥 RESPONSE SUCCESS: ${response.success}");
      print("🔥 RESPONSE STATUS: ${response.statusCode}");

      // Validate response
      if (!response.success || response.data == null) {
        print(
          "❌ INVALID RESPONSE: success=${response.success}, data=${response.data}",
        );
        throw Exception(
          "Failed to get user data: ${response.error?.message ?? 'Unknown error'}",
        );
      }

      final json = response.data!;

      // 🔥 DEBUG KEYS
      print("🔍 RESPONSE KEYS: ${json.keys}");

      // Extract user data from response
      Map<String, dynamic> userData;

      if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
        userData = json['data'] as Map<String, dynamic>;
        print("🔍 USING WRAPPED DATA: $userData");
      } else {
        userData = json;
        print("🔍 USING DIRECT DATA: $userData");
      }

      print("🔍 PARSING USER DATA: $userData");

      if (userData.isEmpty) {
        throw Exception("User data is empty");
      }

      final authUser = AuthUser.fromJson(userData);
      print("✅ SUCCESSFULLY PARSED AUTH USER: ${authUser.name}");

      // Return successful response
      return ApiResponse<AuthUser>(
        success: true,
        data: authUser,
        statusCode: response.statusCode,
      );
    } catch (e, stack) {
      print("💥 ERROR in getCurrentUser: $e");
      print("📍 STACK TRACE: $stack");

      // Return failure response instead of null
      return ApiResponse<AuthUser>(
        success: false,
        error: ApiError(code: 'GET_USER_ERROR', message: e.toString()),
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<void>> forgotPassword({required String email}) {
    return _api.post<void>(ApiEndpoints.forgotPassword, data: {'email': email});
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
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }
}
