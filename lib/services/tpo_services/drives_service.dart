import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';

class DrivesService {
  static const String baseUrl = "https://backend.gyaanplant.in";

  Future<List<Drive>> fetchDrives() async {
    final token = await LocalStorageService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/drive"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
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
