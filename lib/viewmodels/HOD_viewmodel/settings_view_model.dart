import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/HOD_models/settings_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class SettingsViewModel extends ChangeNotifier {
  static const _tag = 'HODSettingsViewModel';

  SettingsModel? user;
  bool isLoading = false;
  bool isLoaded = false;
  String? errorMessage;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> fetchUser() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      final response = await apiService.auth.getCurrentUser();

      if (response.success && response.data != null) {
        final authUser = response.data!;

        // Generate initials from name
        final nameParts = authUser.name.split(' ');
        final initials = nameParts.length >= 2
            ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
            : nameParts.isNotEmpty
            ? nameParts[0][0].toUpperCase()
            : 'U';

        user = SettingsModel(
          name: authUser.name,
          role: authUser.role,
          college: authUser.college?.name ?? 'Unknown College',
          initials: initials,
        );
        isLoaded = true;
        AppLogger.info(_tag, 'Settings user loaded: ${authUser.name}');
      } else {
        throw Exception(response.error?.message ?? 'Failed to load user data');
      }
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to load settings user', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
