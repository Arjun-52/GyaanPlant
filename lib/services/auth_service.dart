import 'package:shared_preferences/shared_preferences.dart';
import '../network/auth_cache.dart';

class AuthService {
  /// Get token from in-memory cache (for backward compatibility)
  static String? get token => AuthCache.token;

  static Future<void> saveToken(String newToken) async {
    // Update in-memory cache
    AuthCache.token = newToken;

    // Persist to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", newToken);
  }

  static Future<void> loadToken() async {
    // Load from storage and cache in memory
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    AuthCache.token = token;
  }

  /// Clear token (logout)
  static Future<void> clearToken() async {
    // Clear in-memory cache
    AuthCache.token = null;

    // Remove from storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
