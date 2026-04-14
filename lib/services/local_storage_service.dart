import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _tokenKey = "auth_token";

  /// Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Clear token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static const String _userKey = "user";

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }
}
