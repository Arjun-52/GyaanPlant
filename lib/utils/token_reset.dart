import 'package:gyaanplant/services/student_services/local_storage_service.dart';

/// Utility to clear stored token for debugging JWT issues
class TokenReset {
  /// Clear all stored authentication data
  static Future<void> clearAllAuthData() async {
    print("🧹 Clearing stored authentication data...");
    
    try {
      await LocalStorageService.clearToken();
      print("✅ Token cleared successfully");
    } catch (e) {
      print("❌ Error clearing token: $e");
    }
  }
  
  /// Check current token status
  static Future<void> checkTokenStatus() async {
    print("🔍 Checking current token status...");
    
    try {
      final token = await LocalStorageService.getToken();
      
      if (token == null) {
        print("❌ No token found in storage");
      } else if (token.isEmpty) {
        print("⚠️ Token exists but is empty");
      } else {
        print("✅ Token found:");
        print("   Length: ${token.length} characters");
        print("   Preview: ${token.length > 20 ? token.substring(0, 20) + '...' : token}");
      }
    } catch (e) {
      print("❌ Error checking token: $e");
    }
  }
}
