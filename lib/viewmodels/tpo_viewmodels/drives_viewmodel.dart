import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class DrivesViewModel extends ChangeNotifier {
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
    // Prevent multiple concurrent API calls
    if (_isLoading) {
      print('⚠️ fetchDrives() already in progress, skipping');
      return;
    }

    print('🚀 DrivesViewModel.fetchDrives() called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📡 Calling API: _tpo.getDrives()');
      final result = await _tpo.getDrives();
      print(
        '📦 API Response: isSuccess=${result.isSuccess}, data=${result.data}',
      );

      if (result.isSuccess) {
        _drives = result.data ?? [];
        print('✅ Successfully loaded ${_drives.length} drives');
      } else {
        print('❌ API Error: ${result.error?.message}');
        throw Exception(result.error?.message ?? 'Failed to load drives');
      }
    } catch (e) {
      print('💥 Exception in fetchDrives(): $e');
      _error = e.toString();
      _drives = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 fetchDrives() completed');
    }
  }

  /// Locally append a newly created drive to the in-memory list.
  ///
  /// TODO: wire to a backend create-drive endpoint when available. Today the
  /// frontend constructs the Drive locally and inserts here; a real
  /// integration should POST first and trust the server's response.
  Future<void> addDrive(Drive drive) async {
    _drives = [drive, ..._drives];
    notifyListeners();
  }

  // Force refresh - bypasses loading guard
  Future<void> refreshDrives() async {
    print('🔄 DrivesViewModel.refreshDrives() called - force refresh');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📡 Calling API: _tpo.getDrives() (refresh)');
      final result = await _tpo.getDrives();
      print(
        '📦 API Response: isSuccess=${result.isSuccess}, data=${result.data}',
      );

      if (result.isSuccess) {
        _drives = result.data ?? [];
        print('✅ Successfully refreshed ${_drives.length} drives');
      } else {
        print('❌ API Error: ${result.error?.message}');
        throw Exception(result.error?.message ?? 'Failed to refresh drives');
      }
    } catch (e) {
      print('💥 Exception in refreshDrives(): $e');
      _error = e.toString();
      _drives = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 refreshDrives() completed');
    }
  }
}
