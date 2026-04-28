class Drive {
  final String company;
  final String role;
  final String date;
  final int eligible;
  final int registered;
  final int pending;
  final String status;

  Drive({
    required this.company,
    required this.role,
    required this.date,
    required this.eligible,
    required this.registered,
    required this.pending,
    required this.status,
  });

  factory Drive.fromJson(Map<String, dynamic> json) {
    return Drive(
      company: json['company'] ?? '',
      role: json['role'] ?? '',
      date: json['date'] ?? '',
      eligible: json['eligible'] ?? 0,
      registered: json['registered'] ?? 0,
      pending: json['pending'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}
