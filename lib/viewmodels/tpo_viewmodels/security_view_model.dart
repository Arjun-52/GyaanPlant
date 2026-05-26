import 'package:flutter/material.dart';

class SecurityViewModel extends ChangeNotifier {
  bool isLoading = false;

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
