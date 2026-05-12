import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/mentor_models/sessions_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class SessionViewModel extends ChangeNotifier {
  static const _tag = 'SessionViewModel';

  final _mentor = ApiService().mentor;

  List<Session> sessions = [];
  bool isLoading = false;
  String? error;
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

  Future<void> loadSessions() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _mentor.getSessions();
      if (result.isSuccess) {
        sessions = result.data ?? [];
        AppLogger.info(_tag, 'Loaded ${sessions.length} sessions');
      } else {
        sessions = [];
        error = result.error?.message ?? 'Failed to load sessions';
        AppLogger.error(_tag, error!);
      }
    } catch (e, st) {
      sessions = [];
      error = e.toString();
      AppLogger.error(_tag, 'Failed to load sessions', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  List<Session> get completed => sessions.where((s) => s.status == 'completed').toList();
}
