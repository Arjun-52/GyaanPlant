import 'dart:convert';
import 'package:gyaanplant/models/HOD_models/department_model.dart';
import 'package:http/http.dart' as http;

class DeptService {
  final String baseUrl = "http://10.0.2.2:5000/api/v1/departments";

  Future<List<Department>> fetchDepts(String token) async {
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List? ?? [])
          .map((e) => Department.fromJson(e))
          .toList();
    } else {
      throw Exception(data["message"] ?? "Failed to load departments");
    }
  }
}
