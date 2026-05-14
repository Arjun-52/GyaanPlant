class MentorSession {
  final String studentName;
  final String topic;
  final String time;

  MentorSession({
    required this.studentName,
    required this.topic,
    required this.time,
  });

  factory MentorSession.fromJson(Map<String, dynamic> json) {
    return MentorSession(
      studentName: json['studentName'] ?? "Student",
      topic: json['topic'] ?? "Mentoring",
      time: json['time'] ?? "TBD",
    );
  }
}
