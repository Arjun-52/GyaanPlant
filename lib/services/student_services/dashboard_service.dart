import 'dart:convert';
import 'package:gyaanplant/data/services/local_storage_service.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import 'base_api_service.dart';

class DashboardService {
  Future<DashboardModel> getDashboard() async {
    final token = await LocalStorageService.getToken();
    print("🔐 TOKEN CHECK: $token");

    final response = await BaseApiService.get('/api/v1/dashboard/student');

    print("🔥 STATUS CODE: ${response.statusCode}");
    print("🔥 RAW RESPONSE: ${response.body}");

    final responseData = jsonDecode(response.body);

    print("🔥 DECODED JSON: $responseData");

    dynamic data;

    if (responseData is Map && responseData.containsKey('data')) {
      data = responseData['data'];

      if (data is Map && data.containsKey('dashboard')) {
        data = data['dashboard'];
      }
    } else {
      data = responseData;
    }

    print("🔥 FINAL DATA USED: $data");

    if (data == null) {
      throw Exception("Dashboard data is null");
    }

    return DashboardModel.fromJson(data);
  }
}
