import '../network/auth_cache.dart';

/// Thin façade over AuthCache for backward-compatibility.
/// All durable storage is handled by LocalStorageService (secure storage).
class AuthService {
  static String? get token => AuthCache.token;
}
