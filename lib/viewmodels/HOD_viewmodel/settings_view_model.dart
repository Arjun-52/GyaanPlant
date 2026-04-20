import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/HOD_models/settings_model.dart';

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
      // TODO: replace with real API call
      await Future.delayed(const Duration(seconds: 1));

      user = SettingsModel(
        name: 'Dr. V. Prakash',
        role: 'Principal',
        college: 'GRIET Hyderabad',
        initials: 'VP',
      );
      isLoaded = true;
      AppLogger.info(_tag, 'Settings user loaded');
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to load settings user', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
