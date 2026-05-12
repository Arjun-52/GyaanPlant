import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../../models/mentor_models/mentor_dashboard_model.dart';
import '../../data/services/api_service.dart';

class MentorProfileViewModel extends ChangeNotifier {
  static const _tag = 'MentorProfileViewModel';

  final _mentor = ApiService().mentor;

  MentorDashboardModel? dashboard;
  bool isLoading = false;
  bool isSaving = false;
  String? error;
  bool _disposed = false;

  List<String> _expertise = [];
  Map<String, List<String>> _availability = {};
  bool _hasChanges = false;

  bool get hasChanges => _hasChanges;
  String get name => dashboard?.name ?? 'Mentor';
  String get role => dashboard?.role ?? 'FSD';
  double get rating => dashboard?.rating ?? 0.0;
  int get sessions => dashboard?.sessionsDone ?? 0;

  List<String> get expertise =>
      _expertise.isNotEmpty ? _expertise : ['Data Structures', 'System Design'];

  Map<String, List<String>> get availability => _availability.isNotEmpty
      ? _availability
      : {'Mon': ['3 PM'], 'Tue': ['4 PM']};

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> loadProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _mentor.getDashboard();

      if (result.isSuccess && result.data != null) {
        dashboard = result.data;
        _expertise = List.from(dashboard!.skills);
        _availability = Map.from(dashboard!.availability);
        AppLogger.info(_tag, 'Profile loaded: ${dashboard!.name}');
      } else {
        dashboard = null;
        error = result.error?.message ?? 'Failed to load profile';
        AppLogger.error(_tag, error!);
      }
    } catch (e, st) {
      dashboard = null;
      error = e.toString();
      AppLogger.error(_tag, 'Failed to load profile', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void toggleExpertise(String skill) {
    if (_expertise.contains(skill)) {
      _expertise.remove(skill);
    } else {
      _expertise.add(skill);
    }
    _hasChanges = true;
    notifyListeners();
  }

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

  Future<void> saveProfile() async {
    if (!_hasChanges) return;

    isSaving = true;
    notifyListeners();

    try {
      final result = await _mentor.updateProfile({
        'skills': _expertise,
        'availability': _availability,
      });

      if (result.isSuccess) {
        _hasChanges = false;
        AppLogger.info(_tag, 'Profile saved');
      } else {
        AppLogger.error(_tag, result.error?.message ?? 'Save failed');
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to save profile', e, st);
    } finally {
      isSaving = false;
      if (!_disposed) notifyListeners();
    }
  }
}
