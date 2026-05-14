import 'package:flutter/material.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/student_role_models/mentor_model.dart';

class MentorViewModel extends ChangeNotifier {
  final _api = ApiService();

  List<MentorModel> mentors = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchMentors() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _api.mentor.getMentors();

      if (result.isSuccess && result.data != null) {
        mentors = result.data!;
        print("✅ MENTORS COUNT: ${mentors.length}");
      } else {
        mentors = [];
        error = result.error?.message ?? "Failed to load mentors";
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
