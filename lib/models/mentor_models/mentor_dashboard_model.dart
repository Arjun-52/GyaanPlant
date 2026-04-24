class MentorDashboardModel {
  final String name;
  final String role;
  final int sessionsDone;
  final int earnings;
  final double rating;

  MentorDashboardModel({
    required this.name,
    required this.role,
    required this.sessionsDone,
    required this.earnings,
    required this.rating,
  });

  factory MentorDashboardModel.fromJson(Map<String, dynamic> json) {
    return MentorDashboardModel(
      name: json['name'] ?? "",
      role: json['role'] ?? "",
      sessionsDone: json['sessionsDone'] ?? 0,
      earnings: json['earnings'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
