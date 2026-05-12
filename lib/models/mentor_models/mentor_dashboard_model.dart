import 'package:gyaanplant/models/mentor_models/mentor_session.dart';

class MentorDashboardModel {
  final String name;
  final String role;
  final int sessionsDone;
  final int earnings;
  final double rating;
  final List<String> skills;
  final Map<String, List<String>> availability;

  final List<MentorSession> upcomingSessions;
  final List<MentorSession> recentSessions;

  MentorDashboardModel({
    required this.name,
    required this.role,
    required this.sessionsDone,
    required this.earnings,
    required this.rating,
    required this.skills,
    required this.availability,
    required this.upcomingSessions,
    required this.recentSessions,
  });

  factory MentorDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json;
    final mentor = data['mentor'] ?? {};

    return MentorDashboardModel(
      name: mentor['name'] ?? "Mentor",
      role: mentor['designation'] ?? mentor['role'] ?? "Mentor",
      sessionsDone: mentor['sessionsCompleted'] ?? 0,
      earnings: mentor['totalEarnings'] ?? 0,
      rating: (mentor['rating'] is num)
          ? (mentor['rating'] as num).toDouble()
          : 0.0,
      skills: (mentor['skills'] is List)
          ? List<String>.from(mentor['skills'])
          : [],
      availability: _parseAvailability(mentor['availability']),

      upcomingSessions: (data['upcomingSessions'] as List? ?? [])
          .map((e) => MentorSession.fromJson(e))
          .toList(),

      recentSessions: (data['recentSessions'] as List? ?? [])
          .map((e) => MentorSession.fromJson(e))
          .toList(),
    );
  }

  static Map<String, List<String>> _parseAvailability(dynamic data) {
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(
          key.toString(),
          (value is List) ? List<String>.from(value) : [],
        ),
      );
    }
    return {};
  }
}
