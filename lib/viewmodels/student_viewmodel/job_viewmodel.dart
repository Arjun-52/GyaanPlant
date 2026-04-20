import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/student_role_models/job_model.dart';
import 'package:gyaanplant/services/student_services/job_service.dart';

class JobViewModel extends ChangeNotifier {
  static const _tag = 'JobViewModel';
  final JobService _service = JobService();

  List<JobModel> jobs = [];
  bool isLoading = false;
  bool isLoaded = false;
  int selectedFilter = 0;
  String? errorMessage;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> fetchJobs() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      jobs = await _service.getJobs();
      isLoaded = true;
      AppLogger.info(_tag, 'Loaded ${jobs.length} jobs');
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to fetch jobs', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectFilter(int index) {
    selectedFilter = index;
    notifyListeners();
  }
}
