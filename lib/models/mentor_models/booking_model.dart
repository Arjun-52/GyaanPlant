class Booking {
  final String name;
  final String college;
  final String time;
  final String topic;
  final int price;
  final String status;

  Booking({
    required this.name,
    required this.college,
    required this.time,
    required this.topic,
    required this.price,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      name: json['student']?['name'] ?? "Student",
      college: json['student']?['branch'] ?? "College",
      time: json['scheduledAt'] ?? "TBD",
      topic: json['topic'] ?? "Session",
      price: json['price'] ?? 0,
      status: json['status'] ?? "pending",
    );
  }
}
