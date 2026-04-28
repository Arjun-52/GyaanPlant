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
    final mentor = json['data']['mentor'];

    return MentorDashboardModel(
      name: "Mentor",
      role: mentor['designation'] ?? "",
      sessionsDone: mentor['sessionsCompleted'] ?? 0,
      earnings: mentor['totalEarnings'] ?? 0,
      rating: (mentor['rating'] ?? 0).toDouble(),
      skills: List<String>.from(mentor['skills'] ?? []),
      availability: {},
    );
  }
}
