import 'package:flutter/material.dart';
import 'package:gyaanplant/services/hod_services/analytics_service.dart';
import 'package:gyaanplant/services/auth_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsService _service = AnalyticsService();

  Map<String, dynamic>? analyticsData;
  bool isLoading = false;
  String? error;

  // Legacy data for existing UI with safety checks
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

  // New fields for requirements with safety checks
  List<dynamic> get departments {
    final list = analyticsData?['departments'] as List? ?? [];
    print(
      "🔍 DEPARTMENTS GETTER: Raw list type=${list.runtimeType}, length=${list.length}",
    );
    return list;
  }

  List<dynamic> get readiness {
    final list = analyticsData?['readiness'] as List? ?? [];
    print(
      "🔍 READINESS GETTER: Raw list type=${list.runtimeType}, length=${list.length}",
    );
    return list;
  }

  Map<String, dynamic> get placementStats {
    final map = analyticsData?['placementStats'] as Map? ?? {};
    print(
      "🔍 PLACEMENT STATS GETTER: Map type=${map.runtimeType}, keys=${map.keys.toList()}",
    );
    // Convert to Map<String, dynamic> for type safety
    return Map<String, dynamic>.from(map);
  }

  List<dynamic> get topPerformers {
    final list = analyticsData?['topPerformers'] as List? ?? [];
    print(
      "🔍 TOP PERFORMERS GETTER: Raw list type=${list.runtimeType}, length=${list.length}",
    );
    return list;
  }

  List<dynamic> get lowPerformers {
    final list = analyticsData?['lowPerformers'] as List? ?? [];
    print(
      "🔍 LOW PERFORMERS GETTER: Raw list type=${list.runtimeType}, length=${list.length}",
    );
    return list;
  }

  Future<void> fetchAnalytics() async {
    final token = AuthService.token;
    if (token == null) throw Exception("User not logged in");

    print("TOKEN USED: $token");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      analyticsData = await _service.fetchAnalytics(token);
      print("ANALYTICS RESPONSE: $analyticsData");

      // Extract data for debugging
      print("DEPARTMENTS LENGTH: ${departments.length}");
      print("READINESS LENGTH: ${readiness.length}");
      print("PLACEMENT STATS: $placementStats");
      print("TOP PERFORMERS LENGTH: ${topPerformers.length}");
      print("LOW PERFORMERS LENGTH: ${lowPerformers.length}");

      // Debug list contents
      if (departments.isNotEmpty) {
        print("DEPARTMENTS DATA: ${departments.take(3).toList()}");
      }
      if (readiness.isNotEmpty) {
        print("READINESS DATA: ${readiness.take(3).toList()}");
      }
      if (topPerformers.isNotEmpty) {
        print("TOP PERFORMERS DATA: ${topPerformers.take(3).toList()}");
      }
      if (lowPerformers.isNotEmpty) {
        print("LOW PERFORMERS DATA: ${lowPerformers.take(3).toList()}");
      }
    } catch (e) {
      print("ANALYTICS ERROR: $e");
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
