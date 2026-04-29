import '../models/mentor_models/booking_model.dart';
import '../models/mentor_models/mentor_dashboard_model.dart';
import '../models/mentor_models/sessions_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class MentorRepository {
  final NetworkAPIManager _api;
  MentorRepository(this._api);

  Future<ApiResponse<MentorDashboardModel>> getDashboard() {
    print("=== MENTOR REPOSITORY DEBUG ===");
    print("Calling Mentor Dashboard API");
    print("ENDPOINT: ${ApiEndpoints.dashboardMentor}");

    try {
      final result = _api.get<MentorDashboardModel>(
        ApiEndpoints.dashboardMentor,
        fromJson: (json) {
          print("=== PARSING MENTOR DASHBOARD RESPONSE ===");
          print("RAW JSON: $json");

          try {
            final map = json as Map<String, dynamic>;
            print("JSON MAP KEYS: ${map.keys.toList()}");

            if (map.containsKey('data')) {
              final data = map['data'] as Map<String, dynamic>;
              print("DATA KEYS: ${data.keys.toList()}");
              print("DATA TYPE: ${data.runtimeType}");

              final dashboard = MentorDashboardModel.fromJson(data);
              print("MENTOR DASHBOARD MODEL CREATED SUCCESSFULLY");
              print("DASHBOARD TYPE: ${dashboard.runtimeType}");
              return dashboard;
            } else {
              print("❌ NO 'data' FIELD IN RESPONSE");
              throw Exception("Response missing 'data' field");
            }
          } catch (e) {
            print("❌ PARSING ERROR: $e");
            print("❌ JSON TYPE: ${json.runtimeType}");
            rethrow;
          }
        },
      );

      print("✅ MENTOR DASHBOARD API CALL INITIATED");
      return result;
    } catch (e) {
      print("❌ MENTOR DASHBOARD API ERROR: $e");
      print("❌ ERROR TYPE: ${e.runtimeType}");
      rethrow;
    }
  }

  Future<ApiResponse<List<Booking>>> getBookings() {
    return _api.get<List<Booking>>(
      ApiEndpoints.sessionMy,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => Booking.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<List<Session>>> getSessions() {
    return _api.get<List<Session>>(
      ApiEndpoints.sessionMy,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => Session.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
