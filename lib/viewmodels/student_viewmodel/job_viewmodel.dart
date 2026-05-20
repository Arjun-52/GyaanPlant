import 'package:flutter/material.dart';

import '../../core/utils/app_logger.dart';
import '../../data/services/api_service.dart';
import '../../models/drive/drive_model.dart';
<<<<<<< Updated upstream
=======
import '../../network/auth_cache.dart';
>>>>>>> Stashed changes

class JobViewModel extends ChangeNotifier {
  static const _tag = 'JobViewModel';

  final _drive = ApiService().drive;

  List<DriveModel> jobs = [];
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

<<<<<<< Updated upstream
=======
    // Check token before API call
    final token = AuthCache.token;
    print(
      "🔑 TOKEN: ${token != null ? 'Present (${token.length} chars)' : 'MISSING'}",
    );

    if (isLoaded) {
      print("⚠️ Already loaded, skipping API call");
      return;
    }

    print("🌐 JOBS API URL: /api/v1/drive");
>>>>>>> Stashed changes
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _drive.getDrives();

<<<<<<< Updated upstream
      if (result.isSuccess && result.data != null) {
        jobs = result.data!.drives;
        isLoaded = true;
        AppLogger.info(_tag, 'Loaded ${jobs.length} jobs');
=======
      print("📦 STATUS: ${result.isSuccess ? 'SUCCESS' : 'FAILED'}");
      if (result.isSuccess) {
        print("📊 RESPONSE DATA: ${result.data}");

        if (result.data != null) {
          jobs = result.data!.drives;
          isLoaded = true;
          print("✅ JOBS STORED: ${jobs.length} jobs loaded");

          // Log first job details for debugging
          if (jobs.isNotEmpty) {
            final firstJob = jobs.first;
            print(
              "🔍 FIRST JOB: id=${firstJob.id}, role=${firstJob.role}, companyName=${firstJob.companyName}",
            );
          }
        } else {
          print("❌ RESULT DATA IS NULL");
          errorMessage = 'API returned null data';
        }
>>>>>>> Stashed changes
      } else {
        errorMessage = result.error?.message ?? 'Failed to fetch jobs';
        AppLogger.error(_tag, errorMessage!);
      }
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to fetch jobs', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void selectFilter(int index) {
    selectedFilter = index;
    notifyListeners();
  }
}
