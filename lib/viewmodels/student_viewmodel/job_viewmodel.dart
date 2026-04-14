import 'package:flutter/material.dart';
import 'package:gyaanplant/models/job_model.dart';
import 'package:gyaanplant/services/job_service.dart';

class JobViewModel extends ChangeNotifier {
  final JobService _service = JobService();

  List<JobModel> jobs = [];
  bool isLoading = false;
  int selectedFilter = 0;

  Future<void> fetchJobs() async {
    isLoading = true;
    notifyListeners();

    try {
      jobs = await _service.getJobs();
    } catch (e) {
      print("Job fetch error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void selectFilter(int index) {
    selectedFilter = index;
    notifyListeners();
  }
}
