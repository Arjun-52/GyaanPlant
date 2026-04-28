import 'package:flutter/material.dart';
import 'package:gyaanplant/services/hod_services/analytics_service.dart';
import 'package:gyaanplant/services/auth_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsService _service = AnalyticsService();

  Map<String, dynamic>? analyticsData;
  bool isLoading = false;
  String? error;
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

  List<int> get monthlyActive {
    final list = (analyticsData?['monthlyActive'] as List? ?? []);
    return list.map((e) => e as int).toList();
  }

  List<int> get placementRates {
    final list = (analyticsData?['placementRates'] as List? ?? []);
    return list.map((e) => e as int).toList();
  }

  int get activeStudents => analyticsData?['activeStudents'] ?? 0;
  double get avgHours => (analyticsData?['avgHours'] ?? 0).toDouble();
  int get readinessScore => analyticsData?['readinessScore'] ?? 0;
  int get certificates => analyticsData?['certificates'] ?? 0;

  List<dynamic> get departments => analyticsData?['departments'] as List? ?? [];
  List<dynamic> get readiness => analyticsData?['readiness'] as List? ?? [];
  Map<String, dynamic> get placementStats =>
      Map<String, dynamic>.from(analyticsData?['placementStats'] as Map? ?? {});
  List<dynamic> get topPerformers => analyticsData?['topPerformers'] as List? ?? [];
  List<dynamic> get lowPerformers => analyticsData?['lowPerformers'] as List? ?? [];

  Future<void> fetchAnalytics() async {
    final token = AuthService.token;
    if (token == null) throw Exception('User not logged in');

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      analyticsData = await _service.fetchAnalytics(token);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
