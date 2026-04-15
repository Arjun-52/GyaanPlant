class Drive {
  final String company;
  final String role;
  final String date;
  final int eligible;
  final int registered;
  final int pending;
  final String status; // Upcoming / Open

  Drive({
    required this.company,
    required this.role,
    required this.date,
    required this.eligible,
    required this.registered,
    required this.pending,
    required this.status,
  });
}
