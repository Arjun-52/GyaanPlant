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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _tpo.getDrives();
      if (result.isSuccess) {
        _drives = result.data ?? [];
      } else {
        throw Exception(result.error?.message ?? 'Failed to load drives');
      }
    } catch (e) {
      _error = e.toString();
      _drives = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
