// lib/repositories/student_purchase_repository.dart
import 'package:gyaanplant/network/api_endpoints.dart';
import 'package:gyaanplant/network/api_manager.dart';
import 'package:gyaanplant/network/api_response.dart';
import 'package:gyaanplant/models/student_purchase_models.dart';

class StudentPurchaseRepository {
  final NetworkAPIManager _api;
  StudentPurchaseRepository({NetworkAPIManager? api}) : _api = api ?? NetworkAPIManager.instance;

  Future<StudentPurchaseStats> fetchStats() async {
    final response = await _api.get<StudentPurchaseStats>(
      ApiEndpoints.paymentStats,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final data = (map['data'] ?? map) as Map<String, dynamic>;
        return StudentPurchaseStats.fromJson(data);
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?.message ?? 'Failed to load purchase stats');
  }

  Future<Map<String, dynamic>> fetchPayments({int page = 1, int limit = 15}) async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.tenantPayments,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'] ?? map;
        if (data is List) {
          return {'items': data, 'pagination': {'total': data.length}};
        }
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        return {};
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?.message ?? 'Failed to load payments');
  }
}
