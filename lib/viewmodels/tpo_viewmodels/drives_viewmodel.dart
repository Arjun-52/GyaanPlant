import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/drive_model.dart';
import 'package:gyaanplant/services/tpo_services/drives_service.dart';

class DrivesViewModel extends ChangeNotifier {
  final DrivesService _service = DrivesService();

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
      _drives = await _service.fetchDrives();
    } catch (e) {
      _error = e.toString();
      _drives = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
