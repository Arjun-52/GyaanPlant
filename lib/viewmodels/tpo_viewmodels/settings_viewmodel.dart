import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/tpo_role_models/settings_item_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class SettingsViewModel extends ChangeNotifier {
  static const _tag = 'TpoSettingsViewModel';

  bool _disposed = false;

  String userName = '';
  String collegeName = '';

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
      title: 'Notification Preferences',
      subtitle: 'WhatsApp, email alerts',
      icon: '🔔',
    ),
    SettingsItem(
      title: 'Parent Report Schedule',
      subtitle: 'Monthly • Auto-send on 1st',
      icon: '📅',
    ),
    SettingsItem(
      title: 'College Profile',
      subtitle: 'Loading...',
      icon: '🏫',
    ),
    SettingsItem(
      title: 'API Integrations',
      subtitle: 'Naukri, LinkedIn Jobs connected',
      icon: '🔗',
    ),
    SettingsItem(
      title: 'Security & Privacy',
      subtitle: '2FA enabled',
      icon: '🔒',
    ),
  ];

  List<SettingsItem> get items => _items;

  Future<void> fetchCollegeName() async {
    try {
      final userResult = await ApiService().auth.getCurrentUser();

      if (userResult.isSuccess && userResult.data != null) {
        final user = userResult.data!;
        userName = user.name;

        final college = user.college;
        if (college != null && college.id != null) {
          final collegeResult = await ApiService().college.getCollegeById(college.id!);

          if (collegeResult.isSuccess && collegeResult.data != null) {
            final data = collegeResult.data!;
            collegeName = data['name']?.toString() ?? 'Unknown College';
          } else {
            collegeName = 'Error loading college';
            AppLogger.error(_tag, collegeResult.error?.message ?? 'College fetch failed');
          }
        } else {
          collegeName = 'No College Assigned';
        }
      } else {
        collegeName = 'Error loading user';
        AppLogger.error(_tag, userResult.error?.message ?? 'User fetch failed');
      }
    } catch (e, st) {
      collegeName = 'Error loading college';
      AppLogger.error(_tag, 'fetchCollegeName failed', e, st);
    }

    _updateCollegeProfileItem();
    notifyListeners();
  }

  void _updateCollegeProfileItem() {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].title == 'College Profile') {
        _items[i] = SettingsItem(
          title: _items[i].title,
          subtitle: collegeName.isNotEmpty ? collegeName : 'Loading...',
          icon: _items[i].icon,
        );
        break;
      }
    }
  }

  void initialize() => fetchCollegeName();
}
