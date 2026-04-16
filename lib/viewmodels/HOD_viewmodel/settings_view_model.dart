import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/settings_model.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsModel? user;
  bool isLoading = false;

  Future<void> fetchUser() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Mock data (replace with API)
    user = SettingsModel(
      name: "Dr. V. Prakash",
      role: "Principal",
      college: "GRIET Hyderabad",
      initials: "VP",
    );

    isLoading = false;
    notifyListeners();
  }
}
