import 'package:gyaanplant/views/tpo_role/reports/services/report_type.dart';

class Report {
  final String title;
  final String subtitle;
  final String icon;
  final bool isPrimary; // for NAAC main card
  final ReportType type;

  Report({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    this.isPrimary = false,
  });
}
