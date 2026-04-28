import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/sessions_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class SessionViewModel extends ChangeNotifier {
  final _mentor = ApiService().mentor;

  List<Session> sessions = [];
  bool isLoading = false;

  Future<void> loadSessions() async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _mentor.getSessions();
      if (result.isSuccess) sessions = result.data ?? [];
    } catch (e) {
      sessions = [];
    }

    isLoading = false;
    notifyListeners();
  }

  List<Session> get completed =>
      sessions.where((s) => s.status == "completed").toList();
}
