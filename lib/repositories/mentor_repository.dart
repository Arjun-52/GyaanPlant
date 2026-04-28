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
    return _api.get<MentorDashboardModel>(
      ApiEndpoints.dashboardMentor,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return MentorDashboardModel.fromJson(map['data'] as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResponse<List<Booking>>> getBookings() {
    return _api.get<List<Booking>>(
      ApiEndpoints.sessionMy,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  Future<ApiResponse<List<Session>>> getSessions() {
    return _api.get<List<Session>>(
      ApiEndpoints.sessionMy,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list.map((e) => Session.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }
}
