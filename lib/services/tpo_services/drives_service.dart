import 'dart:convert';
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';
import 'package:gyaanplant/services/student_services/base_api_service.dart';

import '../../data/services/local_storage_service.dart';

class DrivesService {
  // Using centralized ApiConfig for consistent base URL

  Future<List<Drive>> fetchDrives() async {
    try {
      final response = await BaseApiService.get('/api/v1/drive');

      print("DRIVES STATUS: ${response.statusCode}");
      print("DRIVES BODY: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'] ?? [];

        return data.map<Drive>((e) => Drive.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch drives");
      }
    } catch (e) {
      print("Error fetching drives: $e");
      throw Exception("Failed to fetch drives: ${e.toString()}");
    }
  }
}
