import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String? token;

  static Future<void> saveToken(String newToken) async {
    token = newToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", newToken);
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  /// Clear token (logout)
  static Future<void> clearToken() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
