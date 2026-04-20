import 'dart:convert';
import '../../core/utils/app_logger.dart';
import 'base_api_service.dart';
import '../../models/student_role_models/job_model.dart';

class JobService {
  static const String _tag = 'JobService';

  Future<List<JobModel>> getJobs() async {
    AppLogger.info(_tag, 'Fetching jobs');
    try {
      final response = await BaseApiService.get('/api/v1/drive');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (!responseData.containsKey('data')) {
        AppLogger.warning(_tag, 'No "data" key in response');
        return [];
      }

      final List list = responseData['data'] as List;
      final jobs = list.map((e) => JobModel.fromJson(e as Map<String, dynamic>)).toList();
      AppLogger.info(_tag, 'Fetched ${jobs.length} jobs');
      return jobs;
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to fetch jobs', e, st);
      throw Exception('Failed to fetch jobs: $e');
    }
  }
}
