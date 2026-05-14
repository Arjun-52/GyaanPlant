/// Centralized API Configuration
/// Ensures all services use the same base URL to prevent JWT token issues
class ApiConfig {
  // Single source of truth for API base URL
  static const String baseUrl = "https://backend.gyaanplant.com";

  // API endpoints
  static const String auth = "/api/v1/auth";
  static const String dashboard = "/api/v1/dashboard";
  static const String students = "/api/v1/students";
  static const String drives = "/api/v1/drives";
  static const String departments = "/api/v1/departments";
  static const String analytics = "/api/v1/analytics";

  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);

  // Common headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Build full URL for endpoint
  static String buildUrl(String endpoint) {
    return '$baseUrl${endpoint.startsWith('/') ? endpoint : '/$endpoint'}';
  }

  /// Build authorization header
  static Map<String, String> buildAuthHeaders(String token) {
    return {...headers, 'Authorization': 'Bearer $token'};
  }
}
