import 'package:flutter/material.dart';

import '../../data/services/api_service.dart';
import '../../models/drive/drive_model.dart';
import '../../network/auth_cache.dart';

class JobViewModel extends ChangeNotifier {
  static const _tag = 'JobViewModel';

  final _drive = ApiService().drive;

  List<DriveModel> jobs = [];
  String searchQuery = '';
  bool isLoading = false;
  bool isLoaded = false;
  int selectedFilter = 0;
  String? errorMessage;
  bool _disposed = false;

  List<DriveModel> get filteredJobs {
    List<DriveModel> list = jobs;

    // 1. Filter by chip index
    if (selectedFilter == 1) {
      // Fresher
      list = list.where((job) {
        final r = (job.role ?? '').toLowerCase();
        final d = (job.description ?? '').toLowerCase();
        return r.contains('fresher') || r.contains('junior') || r.contains('entry') ||
               d.contains('fresher') || d.contains('junior') || d.contains('entry');
      }).toList();
    } else if (selectedFilter == 2) {
      // Internships
      list = list.where((job) {
        final r = (job.role ?? '').toLowerCase();
        final d = (job.description ?? '').toLowerCase();
        final t = (job.type ?? '').toLowerCase();
        return r.contains('intern') || d.contains('intern') || t.contains('intern');
      }).toList();
    } else if (selectedFilter == 3) {
      // Remote
      list = list.where((job) {
        final l = (job.location ?? '').toLowerCase();
        final r = (job.role ?? '').toLowerCase();
        return l.contains('remote') || l.contains('wfh') || r.contains('remote');
      }).toList();
    } else if (selectedFilter == 4) {
      // Hyderabad
      list = list.where((job) {
        final l = (job.location ?? '').toLowerCase();
        return l.contains('hyderabad') || l.contains('hyd');
      }).toList();
    }

    // 2. Filter by search query
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      list = list.where((job) {
        final role = (job.role ?? '').toLowerCase();
        final company = (job.companyName ?? '').toLowerCase();
        final location = (job.location ?? '').toLowerCase();
        final skillsMatch = job.skills?.any((s) => s.toLowerCase().contains(query)) ?? false;
        
        return role.contains(query) ||
            company.contains(query) ||
            location.contains(query) ||
            skillsMatch;
      }).toList();
    }

    return list;
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

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
    final token = AuthCache.token;
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
              "🔍 FIRST JOB: id=${firstJob.id}, role=${firstJob.role}, companyName=${firstJob.companyName}",
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
      print("💥 ERROR TYPE: ${e.runtimeType}");
      print("💥 ERROR: $e");
      print("📍 STACK: $st");
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
