class MentorSession {
  final String? sessionId;
  final String studentName;
  final String topic;
  final String time;
  final String? meetingLink;

  MentorSession({
    this.sessionId,
    required this.studentName,
    required this.topic,
    required this.time,
    this.meetingLink,
  });

  factory MentorSession.fromJson(Map<String, dynamic> json) {
    return MentorSession(
      sessionId: json['sessionId']?.toString() ?? json['id']?.toString(),
      studentName: json['studentName'] ?? "Student",
      topic: json['topic'] ?? "Mentoring",
      time: json['time'] ?? "TBD",
      meetingLink: json['meetingLink'] ?? json['meeting_link'],
    );
  }
}
