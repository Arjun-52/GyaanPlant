class Drive {
  final String company;
  final String role;
  final String date;
  final int eligible;
  final int registered;
  final int pending;
  final String status;
  
  final String? driveDate;
  final int? registeredCount;
  final int? shortlistedCount;
  final String? package;
  final String? salary;
  final String? CTC;
  final String? jdUrl;

  Drive({
    required this.company,
    required this.role,
    required this.date,
    required this.eligible,
    required this.registered,
    required this.pending,
    required this.status,
    this.driveDate,
    this.registeredCount,
    this.shortlistedCount,
    this.package,
    this.salary,
    this.CTC,
    this.jdUrl,
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
      driveDate: json['driveDate']?.toString(),
      registeredCount: json['registeredCount'] as int?,
      shortlistedCount: json['shortlistedCount'] as int?,
      package: json['package']?.toString(),
      salary: json['salary']?.toString(),
      CTC: json['CTC']?.toString(),
      jdUrl: json['jdUrl']?.toString(),
    );
  }
}
