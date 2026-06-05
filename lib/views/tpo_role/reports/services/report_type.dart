/// The kinds of report the TPO can generate.
///
/// Used by `ReportService` to route data fetches and by
/// `PdfGeneratorService` to pick the matching layout template.
enum ReportType {
  naac,
  placementSummary,
  skillGapAnalysis,
  departmentReadiness,
  companyDrive,
}
