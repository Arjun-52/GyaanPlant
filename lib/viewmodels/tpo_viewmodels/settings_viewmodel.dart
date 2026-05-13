import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/tpo_role_models/settings_item_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class SettingsViewModel extends ChangeNotifier {
  static const _tag = 'TpoSettingsViewModel';

  bool _disposed = false;

  String userName = '';

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  final List<SettingsItem> _items = [
    SettingsItem(
      title: 'Security & Privacy',
      subtitle: '2FA enabled',
      icon: '🔒',
    ),
  ];

  List<SettingsItem> get items => _items;

  void initialize() {
    // Can be used for future initialization needs
  }
}
