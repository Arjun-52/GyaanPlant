import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  LocalStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _roleKey = 'user_role';
  static const String _availabilityLastUpdatedKey = 'availability_last_updated';
  static const String _availabilityKey = 'mentor_availability';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _availabilityLastUpdatedKey);
    await _storage.delete(key: _availabilityKey);
  }

  static Future<void> saveRole(String role) =>
      _storage.write(key: _roleKey, value: role);

  static Future<String?> getRole() => _storage.read(key: _roleKey);

  static Future<void> removeRole() => _storage.delete(key: _roleKey);

  static Future<void> saveUser(Map<String, dynamic> user) =>
      _storage.write(key: _userKey, value: jsonEncode(user));

  static Future<Map<String, dynamic>?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveAvailabilityLastUpdated(String val) =>
      _storage.write(key: _availabilityLastUpdatedKey, value: val);

  static Future<String?> getAvailabilityLastUpdated() =>
      _storage.read(key: _availabilityLastUpdatedKey);

  static Future<void> saveAvailability(Map<String, List<String>> availability) =>
      _storage.write(key: _availabilityKey, value: jsonEncode(availability));

  static Future<Map<String, List<String>>?> getAvailability() async {
    final raw = await _storage.read(key: _availabilityKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map;
      return decoded.map(
        (key, value) => MapEntry(
          key.toString(),
          (value is List) ? List<String>.from(value) : [],
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
