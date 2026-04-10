import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// LocalStorageService handles local data persistence using SharedPreferences.
/// This service provides methods to store and retrieve data locally on the device.
class LocalStorageService {
  LocalStorageService._(); // Private constructor to prevent instantiation

  /// Gets the SharedPreferences instance
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  /// Stores a string value
  static Future<void> setString(String key, String value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, value);
  }

  /// Retrieves a string value
  static Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }

  /// Stores an integer value
  static Future<void> setInt(String key, int value) async {
    final prefs = await _getPrefs();
    await prefs.setInt(key, value);
  }

  /// Retrieves an integer value
  static Future<int?> getInt(String key) async {
    final prefs = await _getPrefs();
    return prefs.getInt(key);
  }

  /// Stores a boolean value
  static Future<void> setBool(String key, bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(key, value);
  }

  /// Retrieves a boolean value
  static Future<bool?> getBool(String key) async {
    final prefs = await _getPrefs();
    return prefs.getBool(key);
  }

  /// Stores a double value
  static Future<void> setDouble(String key, double value) async {
    final prefs = await _getPrefs();
    await prefs.setDouble(key, value);
  }

  /// Retrieves a double value
  static Future<double?> getDouble(String key) async {
    final prefs = await _getPrefs();
    return prefs.getDouble(key);
  }

  /// Stores a string list
  static Future<void> setStringList(String key, List<String> value) async {
    final prefs = await _getPrefs();
    await prefs.setStringList(key, value);
  }

  /// Retrieves a string list
  static Future<List<String>?> getStringList(String key) async {
    final prefs = await _getPrefs();
    return prefs.getStringList(key);
  }

  /// Stores a JSON object (as a string)
  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, json.encode(value));
  }

  /// Retrieves a JSON object
  static Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Removes a value by key
  static Future<void> remove(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove(key);
  }

  /// Clears all stored data
  static Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  /// Checks if a key exists
  static Future<bool> containsKey(String key) async {
    final prefs = await _getPrefs();
    return prefs.containsKey(key);
  }

  /// Gets all keys
  static Future<Set<String>> getKeys() async {
    final prefs = await _getPrefs();
    return prefs.getKeys();
  }

  // Common storage keys used throughout the app
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String firstLaunchKey = 'first_launch';
  static const String notificationsEnabledKey = 'notifications_enabled';
}
