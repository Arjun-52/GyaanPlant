import 'dart:convert';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import 'base_api_service.dart';

class DashboardService {
  static const String _tag = 'DashboardService';

  Future<DashboardModel> getDashboard() async {
    AppLogger.info(_tag, 'Fetching dashboard');
    final response = await BaseApiService.get('/api/v1/dashboard/student');

    final dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse dashboard response', e);
      throw Exception('Invalid response from server');
    }

    dynamic data;
    if (responseData is Map && responseData.containsKey('data')) {
      data = responseData['data'];
      if (data is Map && data.containsKey('dashboard')) {
        data = data['dashboard'];
      }
    } else {
      data = responseData;
    }

    if (data == null) {
      AppLogger.error(_tag, 'Dashboard data is null');
      throw Exception('Dashboard data is null');
    }

    AppLogger.info(_tag, 'Dashboard fetched successfully');
    return DashboardModel.fromJson(data as Map<String, dynamic>);
  }
}
