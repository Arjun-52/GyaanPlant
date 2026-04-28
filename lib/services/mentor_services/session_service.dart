import 'dart:convert';
import 'package:gyaanplant/models/mentor_models/sessions_model.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../data/services/local_storage_service.dart';

class SessionService {
  Future<List<Session>> fetchSessions() async {
    try {
      final token = await LocalStorageService.getToken();

      print("🔐 SESSION TOKEN: $token");

      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl('/api/v1/session/my')),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("🌐 SESSION RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List list = data['data'] ?? [];

        return list.map<Session>((e) {
          return Session.fromJson(e);
        }).toList();
      } else {
        print("❌ SESSION API ERROR: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ SESSION ERROR: $e");
      return [];
    }
  }
}
