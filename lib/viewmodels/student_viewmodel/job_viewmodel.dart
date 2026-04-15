import 'package:flutter/material.dart';
import 'package:gyaanplant/models/student_role_models/job_model.dart';
import 'package:gyaanplant/services/student_services/job_service.dart';

class JobViewModel extends ChangeNotifier {
  final JobService _service = JobService();

  List<JobModel> jobs = [];
  bool isLoading = false;
  bool isLoaded = false;
  int selectedFilter = 0;

  Future<void> fetchJobs() async {
    print("=== JOB VIEWMODEL DEBUG START ===");
    print("1. fetchJobs() called");
    print("2. isLoaded: $isLoaded");
    print("3. isLoading: $isLoading");
    print("4. current jobs count: ${jobs.length}");

    if (isLoaded) {
      print("5. SKIP: Already loaded, returning");
      return;
    }

    print("6. SETTING isLoading = true");
    isLoading = true;
    notifyListeners();
    print("7. notifyListeners() called for loading state");

    try {
      print("8. CALLING service.getJobs()");
      jobs = await _service.getJobs();
      isLoaded = true;

      print("9. SUCCESS: Received ${jobs.length} jobs");
      print("10. SETTING isLoaded = true");

      if (jobs.isNotEmpty) {
        print("11. FIRST JOB: ${jobs[0].role} at ${jobs[0].companyName}");
      }
    } catch (e) {
      print("=== JOB VIEWMODEL ERROR ===");
      print("ERROR TYPE: ${e.runtimeType}");
      print("ERROR MESSAGE: $e");
      print("STACK TRACE: ${StackTrace.current}");
      print("=== JOB VIEWMODEL ERROR END ===");
    }

    print("12. SETTING isLoading = false");
    isLoading = false;
    print("13. notifyListeners() called for final state");
    notifyListeners();
    print("14. Final jobs count: ${jobs.length}");
    print("=== JOB VIEWMODEL DEBUG END ===");
  }

  void selectFilter(int index) {
    selectedFilter = index;
    notifyListeners();
  }
}
