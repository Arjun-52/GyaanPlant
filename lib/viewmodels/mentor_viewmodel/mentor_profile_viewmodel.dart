import 'package:flutter/material.dart';
import '../../models/mentor_models/mentor_dashboard_model.dart';
import '../../data/services/api_service.dart';

class MentorProfileViewModel extends ChangeNotifier {
  final _mentor = ApiService().mentor;

  MentorDashboardModel? dashboard;
  bool isLoading = false;
  bool isSaving = false;

  ///  LOCAL EDITABLE STATE
  List<String> _expertise = [];
  Map<String, List<String>> _availability = {};

  bool _hasChanges = false;

  bool get hasChanges => _hasChanges;

  ///  LOAD
  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _mentor.getDashboard();

      if (result.isSuccess && result.data != null) {
        dashboard = result.data;

        _expertise = List.from(dashboard!.skills);
        _availability = Map.from(dashboard!.availability);
      }
    } catch (e) {
      dashboard = null;
    }

    isLoading = false;
    notifyListeners();
  }

  /// GETTER
  String get name => dashboard?.name ?? "Mentor";
  String get role => dashboard?.role ?? "FSD";
  double get rating => dashboard?.rating ?? 0.0;
  int get sessions => dashboard?.sessionsDone ?? 0;

  List<String> get expertise =>
      _expertise.isNotEmpty ? _expertise : ["Data Structures", "System Design"];

  Map<String, List<String>> get availability => _availability.isNotEmpty
      ? _availability
      : {
          "Mon": ["3 PM"],
          "Tue": ["4 PM"],
        };

  /// UPDATE EXPERTISE
  void toggleExpertise(String skill) {
    if (_expertise.contains(skill)) {
      _expertise.remove(skill);
    } else {
      _expertise.add(skill);
    }

    _hasChanges = true;
    notifyListeners();
  }

  /// UPDATE AVAILABILITY
  void toggleTime(String day, String time) {
    _availability.putIfAbsent(day, () => []);

    if (_availability[day]!.contains(time)) {
      _availability[day]!.remove(time);
    } else {
      _availability[day]!.add(time);
    }

    _hasChanges = true;
    notifyListeners();
  }

  ///  SAVE
  Future<void> saveProfile() async {
    if (!_hasChanges) return;

    isSaving = true;
    notifyListeners();

    try {
      final result = await _mentor.updateProfile({
        "skills": _expertise,
        "availability": _availability,
      });

      if (result.isSuccess) {
        _hasChanges = false;
      }
    } catch (e) {
      debugPrint("Save error: $e");
    }

    isSaving = false;
    notifyListeners();
  }
}
