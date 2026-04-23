import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/analytics_model.dart';
import 'package:gyaanplant/services/hod_services/analytics_service.dart';
import 'package:gyaanplant/services/auth_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsService _service = AnalyticsService();

  AnalyticsModel? data;
  bool isLoading = false;
  String? error;

  Future<void> loadAnalytics() async {
    final token = AuthService.token;
    if (token == null) throw Exception("User not logged in");

    print("TOKEN USED: $token");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      data = await _service.fetchAnalytics(token);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAnalytics() async {
    final token = AuthService.token;
    if (token == null) throw Exception("User not logged in");

    print("TOKEN USED: $token");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      data = await _service.fetchAnalytics(token);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
