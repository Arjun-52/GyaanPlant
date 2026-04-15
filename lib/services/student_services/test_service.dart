import 'dart:convert';

import 'package:gyaanplant/models/student_role_models/assessment_model.dart';

import 'base_api_service.dart';

class TestService {
  Future<List<AssessmentModel>> getTests() async {
    final res = await BaseApiService.get('/api/v1/learning/assessments');

    if (res.statusCode != 200) {
      throw Exception('Failed to load assessments: ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    final List list = data['data'] ?? [];

    return list.map((e) => AssessmentModel.fromJson(e)).toList();
  }
}
