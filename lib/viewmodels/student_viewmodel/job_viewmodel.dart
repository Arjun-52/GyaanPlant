import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../../data/services/api_service.dart';
import '../../models/drive/drive_model.dart';

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

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _drive.getDrives();
      if (result.isSuccess) {
        jobs = result.data!.drives;
        isLoaded = true;
        AppLogger.info(_tag, 'Loaded ${jobs.length} jobs');
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
