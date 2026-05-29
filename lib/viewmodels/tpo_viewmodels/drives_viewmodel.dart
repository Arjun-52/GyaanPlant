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
    if (_isLoading) {
      print('⚠️ fetchDrives() already in progress, skipping');
      return;
    }

    print('🚀 DrivesViewModel.fetchDrives() called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📡 Calling API: GET ${ApiService().tpo.runtimeType} getDrives()');
      final result = await _tpo.getDrives();
      print(
        '📦 API Response: isSuccess=${result.isSuccess}, statusCode=${result.statusCode}',
      );
      print('📦 Raw drive data: ${result.data}');

      if (result.isSuccess) {
        _drives = result.data ?? [];
        print('✅ Successfully loaded ${_drives.length} drives from backend');
        for (final d in _drives) {
          print('  📋 Drive: ${d.company} | ${d.role} | status=${d.status}');
        }
      } else {
        print('❌ API Error: ${result.error?.message} (code: ${result.error?.code})');
        throw Exception(result.error?.message ?? 'Failed to load drives');
      }
    } catch (e) {
      print('💥 Exception in fetchDrives(): $e');
      _error = e.toString();
      _drives = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 fetchDrives() completed — drives in list: ${_drives.length}');
    }
  }

  /// POST the new drive to the backend, then immediately refresh from the
  /// server so the list always reflects the true database state.
  ///
  /// If the backend create endpoint is not yet wired, the drive is appended
  /// locally AND a refresh is attempted so any persisted drives are shown.
  Future<String?> createDrive(Map<String, dynamic> payload) async {
    print('🚀 DrivesViewModel.createDrive() called');
    print('📨 Final Request Payload: $payload');

    try {
      final result = await _tpo.createDrive(payload);
      print(
        '📦 Create drive response: isSuccess=${result.isSuccess}, statusCode=${result.statusCode}',
      );
      print('📦 Create drive data: ${result.data}');

      if (result.isSuccess) {
        final newlyCreatedDrive = result.data;
        print('✅ Drive created on backend successfully');
        print('🆔 Database ID of newly created drive: ${newlyCreatedDrive?.id}');
        // Refresh from backend so the persisted drive appears in the list
        await refreshDrives();
        return null; // Null means success
      } else {
        print('❌ Create drive API error: ${result.error?.message}');
        return result.error?.message ?? 'Failed to create drive';
      }
    } catch (e) {
      print('💥 Exception in createDrive(): $e');
      return e.toString();
    }
  }

  /// Locally append a drive — kept for backward compat but callers should
  /// prefer [createDrive] which persists to the backend.
  Future<void> addDrive(Drive drive) async {
    print('⚠️ addDrive() called — LOCAL ONLY, not persisted to backend!');
    print('   Prefer createDrive(payload) to persist to the database.');
    _drives = [drive, ..._drives];
    notifyListeners();
  }

  // Force refresh — bypasses loading guard
  Future<void> refreshDrives() async {
    print('🔄 DrivesViewModel.refreshDrives() called — force refresh');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📡 Calling API: getDrives() (refresh)');
      final result = await _tpo.getDrives();
      print(
        '📦 Refresh response: isSuccess=${result.isSuccess}, statusCode=${result.statusCode}',
      );

      if (result.isSuccess) {
        _drives = result.data ?? [];
        print('✅ Successfully refreshed — ${_drives.length} drives loaded');
        for (final d in _drives) {
          print('  📋 Drive: ${d.company} | ${d.role} | status=${d.status}');
        }
      } else {
        print('❌ Refresh API Error: ${result.error?.message}');
        throw Exception(result.error?.message ?? 'Failed to refresh drives');
      }
    } catch (e) {
      print('💥 Exception in refreshDrives(): $e');
      _error = e.toString();
      _drives = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 refreshDrives() completed — drives in list: ${_drives.length}');
    }
  }
}
