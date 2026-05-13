import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class DrivesViewModel extends ChangeNotifier {
  static const _tag = 'DrivesViewModel';

  final _tpo = ApiService().tpo;

  List<Drive> _drives = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<Drive> get drives => _drives;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> fetchDrives() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _tpo.getDrives();

      if (result.isSuccess) {
        _drives = result.data ?? [];
        AppLogger.info(_tag, 'Loaded ${_drives.length} drives');
      } else {
        _error = result.error?.message ?? 'Failed to load drives';
        AppLogger.error(_tag, _error!);
      }
    } catch (e, st) {
      _error = e.toString();
      _drives = [];
      AppLogger.error(_tag, 'Failed to fetch drives', e, st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDrives() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _tpo.getDrives();

      if (result.isSuccess) {
        _drives = result.data ?? [];
        AppLogger.info(_tag, 'Refreshed ${_drives.length} drives');
      } else {
        _error = result.error?.message ?? 'Failed to refresh drives';
        AppLogger.error(_tag, _error!);
      }
    } catch (e, st) {
      _error = e.toString();
      _drives = [];
      AppLogger.error(_tag, 'Failed to refresh drives', e, st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDrive(Drive drive) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, just add the drive to the list locally
      // TODO: Implement actual API call when backend is ready
      _drives.insert(0, drive); // Add new drive at the beginning
      AppLogger.info(_tag, 'Added new drive: ${drive.company}');
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error(_tag, 'Failed to add drive', e, st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
