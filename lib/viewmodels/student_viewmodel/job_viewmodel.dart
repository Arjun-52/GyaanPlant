import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../../data/services/api_service.dart';
import '../../models/drive/drive_model.dart';
import '../../services/auth_service.dart';

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
    print("🚀 CALLING JOBS API - fetchJobs() triggered");

    // Check token before API call
    final token = AuthService.token;
    print(
      "🔑 TOKEN: ${token != null ? 'Present (${token.length} chars)' : 'MISSING'}",
    );

    if (isLoaded) {
      print("⚠️ Already loaded, skipping API call");
      return;
    }

    print("🌐 JOBS API URL: /api/v1/drive");
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print("📡 Making API call to getDrives()...");
      final result = await _drive.getDrives();

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
              "🔍 FIRST JOB: id=${firstJob.id}, title=${firstJob.title}, company=${firstJob.company}",
            );
          }
        } else {
          print("❌ RESULT DATA IS NULL");
          errorMessage = 'API returned null data';
        }
      } else {
        print("❌ API ERROR: ${result.error?.message}");
        errorMessage = result.error?.message ?? 'Failed to fetch jobs';
      }
    } catch (e, st) {
      print("💥 EXCEPTION: $e");
      print("📍 STACK TRACE: $st");
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      print(
        "🔔 notifyListeners() called - isLoading=$isLoading, jobs.length=${jobs.length}",
      );
      if (!_disposed) notifyListeners();
    }
  }

  void selectFilter(int index) {
    selectedFilter = index;
    notifyListeners();
  }
}
