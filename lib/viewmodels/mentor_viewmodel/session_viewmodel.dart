import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/sessions_model.dart';
import 'package:gyaanplant/services/mentor_services/session_service.dart';

class SessionViewModel extends ChangeNotifier {
  final SessionService _service = SessionService();

  List<Session> sessions = [];
  bool isLoading = false;

  Future<void> loadSessions() async {
    isLoading = true;
    notifyListeners();

    sessions = await _service.fetchSessions();

    isLoading = false;
    notifyListeners();
  }

  List<Session> get completed =>
      sessions.where((s) => s.status == "completed").toList();
}
