import 'package:gyaanplant/core/utils/app_logger.dart';
import '../data/services/local_storage_service.dart';

class TokenReset {
  static const _tag = 'TokenReset';

  static Future<void> clearAllAuthData() async {
    try {
      await LocalStorageService.clearToken();
      AppLogger.info(_tag, 'Token cleared');
    } catch (e) {
      AppLogger.error(_tag, 'Error clearing token: $e');
    }
  }

  static Future<void> checkTokenStatus() async {
    try {
      final token = await LocalStorageService.getToken();
      if (token == null) {
        AppLogger.info(_tag, 'No token in storage');
      } else if (token.isEmpty) {
        AppLogger.warning(_tag, 'Token exists but is empty');
      } else {
        AppLogger.info(_tag, 'Token length: ${token.length}');
      }
    } catch (e) {
      AppLogger.error(_tag, 'Error checking token: $e');
    }
  }
}
