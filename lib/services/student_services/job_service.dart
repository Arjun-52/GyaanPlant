import 'dart:convert';

import 'base_api_service.dart';
import '../../models/student_role_models/job_model.dart';

class JobService {
  Future<List<JobModel>> getJobs() async {
    print("=== JOB SERVICE DEBUG START ===");
    print("1. API CALL INITIATED");

    try {
      // Check if base URL is correct
      print("2. CALLING: /api/v1/drive");
      final response = await BaseApiService.get('/api/v1/drive');

      print("3. RESPONSE STATUS: ${response.statusCode}");
      print("4. RESPONSE BODY: ${response.body}");

      if (response.statusCode != 200) {
        print("4. ERROR: Non-200 status code");
        throw Exception('API Error: ${response.statusCode}');
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print("5. DECODED JSON: $responseData");

      // Check response structure
      if (!responseData.containsKey('data')) {
        print("5. ERROR: No 'data' key in response");
        print("Available keys: ${responseData.keys.toList()}");
        return [];
      }

      final List list = responseData['data'];
      print("6. DATA LIST LENGTH: ${list.length}");
      print("7. DATA LIST CONTENT: $list");

      if (list.isEmpty) {
        print("7. INFO: Empty list returned from backend");
        return [];
      }

      final jobs = list.map((e) => JobModel.fromJson(e)).toList();
      print("8. PARSED JOBS COUNT: ${jobs.length}");

      if (jobs.isNotEmpty) {
        print("9. FIRST JOB: ${jobs[0].role} at ${jobs[0].companyName}");
      }

      print("=== JOB SERVICE DEBUG END ===");
      return jobs;
    } catch (e) {
      print("=== JOB SERVICE ERROR ===");
      print("ERROR TYPE: ${e.runtimeType}");
      print("ERROR MESSAGE: $e");
      print("STACK TRACE: ${StackTrace.current}");
      print("=== JOB SERVICE ERROR END ===");
      throw Exception("Failed to fetch jobs: $e");
    }
  }
}
