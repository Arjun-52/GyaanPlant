import '../models/mentor_models/booking_model.dart';
import '../models/mentor_models/mentor_dashboard_model.dart';
import '../models/mentor_models/mentor_earnings_model.dart';
import '../models/mentor_models/sessions_model.dart';
import '../models/student_role_models/mentor_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';
import '../core/utils/app_logger.dart';

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

  Future<ApiResponse<List<MentorModel>>> getMentors() {
    return _api.get<List<MentorModel>>(
      ApiEndpoints.mentors,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => MentorModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> profileData,
  ) {
    return _api.put<Map<String, dynamic>>(
      ApiEndpoints.updateMyProfile,
      data: profileData,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return map['data'] as Map<String, dynamic>? ?? map;
      },
    );
  }

  Future<ApiResponse<MentorEarningsModel>> getMentorEarnings() {
    AppLogger.info('MentorRepository', "🚀 FETCH MENTOR EARNINGS");
    return _api.get<MentorEarningsModel>(
      ApiEndpoints.mentorEarnings,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return MentorEarningsModel.fromJson(map['data'] as Map<String, dynamic>);
      },
    );
  }
}
