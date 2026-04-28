import 'package:flutter/material.dart';
import '../../models/mentor_models/mentor_dashboard_model.dart';
import '../../data/services/api_service.dart';

class MentorProfileViewModel extends ChangeNotifier {
  final _mentor = ApiService().mentor;

  MentorDashboardModel? dashboard;
  bool isLoading = false;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _mentor.getDashboard();
      if (result.isSuccess) dashboard = result.data;
    } catch (e) {
      dashboard = null;
    }

    isLoading = false;
    notifyListeners();
  }

  List<String> get expertise {
    if (dashboard?.skills.isNotEmpty == true) {
      return dashboard!.skills;
    }
    return ["Data Structures", "System Design"];
  }

  Map<String, List<String>> get availability {
    if (dashboard?.availability.isNotEmpty == true) {
      return dashboard!.availability;
    }
    return {
      "Mon": ["3 PM"],
      "Tue": ["4 PM"],
    };
  }
}
