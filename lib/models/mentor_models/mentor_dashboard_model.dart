class MentorDashboardModel {
  final String name;
  final String role;
  final int sessionsDone;
  final int earnings;
  final double rating;
  final List<String> skills;
  final Map<String, List<String>> availability;

  MentorDashboardModel({
    required this.name,
    required this.role,
    required this.sessionsDone,
    required this.earnings,
    required this.rating,
    required this.skills,
    required this.availability,
  });

  factory MentorDashboardModel.fromJson(Map<String, dynamic> json) {
    print("🔍 MENTOR DASHBOARD MODEL PARSING: $json");

    // Handle nested structure
    final mentor = json['mentor'] ?? json;

    print("🔍 MENTOR DATA: $mentor");

    return MentorDashboardModel(
      name: mentor['name'] ?? "Mentor",

      role: mentor['designation'] ?? mentor['role'] ?? "Mentor",

      sessionsDone: mentor['sessionsCompleted'] ?? mentor['sessionsDone'] ?? 0,

      earnings: mentor['totalEarnings'] ?? mentor['earnings'] ?? 0,

      rating: (mentor['rating'] is num)
          ? (mentor['rating'] as num).toDouble()
          : 0.0,

      skills: (mentor['skills'] is List)
          ? List<String>.from(mentor['skills'])
          : [],

      availability: _parseAvailability(mentor['availability']),
    );
  }

  // ✅ Safe parser for availability
  static Map<String, List<String>> _parseAvailability(dynamic data) {
    // Case 1: Correct Map format
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(
          key.toString(),
          (value is List) ? List<String>.from(value) : [],
        ),
      );
    }

    // Case 2: Wrong format (List/null/etc)
    return {};
  }
}
