import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/settings_item_model.dart';

class SettingsViewModel extends ChangeNotifier {
  final List<SettingsItem> items = [
    SettingsItem(
      title: "Notification Preferences",
      subtitle: "WhatsApp, email alerts",
      icon: "🔔",
    ),
    SettingsItem(
      title: "Parent Report Schedule",
      subtitle: "Monthly • Auto-send on 1st",
      icon: "📅",
    ),
    SettingsItem(
      title: "College Profile",
      subtitle: "GRIET • A+ Grade • 2,847 students",
      icon: "🏫",
    ),
    SettingsItem(
      title: "API Integrations",
      subtitle: "Naukri, LinkedIn Jobs connected",
      icon: "🔗",
    ),
    SettingsItem(
      title: "Security & Privacy",
      subtitle: "2FA enabled",
      icon: "🔒",
    ),
  ];
}
