import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';
import 'package:gyaanplant/config/api_config.dart';

class DrivesService {
  // Using centralized ApiConfig for consistent base URL

  Future<List<Drive>> fetchDrives() async {
    final token = await LocalStorageService.getToken();

    final response = await http.get(
      Uri.parse(ApiConfig.buildUrl("/api/v1/drive")),
      headers: token != null
          ? ApiConfig.buildAuthHeaders(token)
          : ApiConfig.headers,
    );

    print("DRIVES STATUS: ${response.statusCode}");
    print("DRIVES BODY: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? [];

      return data.map<Drive>((e) => Drive.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch drives");
    }
  }
}
