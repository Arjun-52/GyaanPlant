class Session {
  final String name;
  final String time;
  final String topic;
  final String status;
  final String review;
  final int rating;
  final int duration;

  Session({
    required this.name,
    required this.time,
    required this.topic,
    required this.status,
    required this.review,
    required this.rating,
    required this.duration,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      name: json['student']?['name'] ?? "Student",

      time: json['scheduledAt'] ?? "",

      topic: json['topic'] ?? "Session",

      status: json['status'] ?? "pending",

      review: json['review'] ?? "",

      rating: json['rating'] ?? 0,

      duration: json['duration'] ?? 30,
    );
  }
}
