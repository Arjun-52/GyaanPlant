import 'dart:convert';

import 'package:http/http.dart' as BaseApiService;

import '../models/job_model.dart';

class JobService {
  Future<List<JobModel>> getJobs() async {
    try {
      final response = await BaseApiService.get(Uri.parse('/api/v1/drive'));

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List list = responseData['data'];

      return list.map((e) => JobModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to fetch jobs: $e");
    }
  }
}
