/// Enum for different report types
enum ReportType {
  naac,
  placementSummary,
  skillGapAnalysis,
  departmentReadiness,
  companyDrive,
}

class Report {
  final String title;
  final String subtitle;
  final String icon;
  final bool isPrimary; // for NAAC main card
  final ReportType? reportType;

  Report({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isPrimary = false,
    this.reportType,
  });
}
