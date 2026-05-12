import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/student_role_models/mentor_model.dart';

class MentorViewModel extends ChangeNotifier {
  static const _tag = 'MentorViewModel';

  final _api = ApiService();

  List<MentorModel> mentors = [];
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

  Future<void> fetchMentors() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _api.mentor.getMentors();

      if (result.isSuccess && result.data != null) {
        mentors = result.data!;
        AppLogger.info(_tag, 'Loaded ${mentors.length} mentors');
      } else {
        mentors = [];
        error = result.error?.message ?? 'Failed to load mentors';
        AppLogger.error(_tag, error!);
      }
    } catch (e, st) {
      error = e.toString();
      AppLogger.error(_tag, 'Failed to load mentors', e, st);
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }
}
