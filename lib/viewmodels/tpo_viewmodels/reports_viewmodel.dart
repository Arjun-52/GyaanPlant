import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/report_model.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/report_service.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/pdf_generator_service.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';

class ReportsViewModel extends ChangeNotifier {
  static const _tag = 'ReportsViewModel';

  bool _disposed = false;
  Map<String, bool> _downloadingStates = {};

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  final List<Report> reports = [
    Report(
      title: "Generate NAAC Report",
      subtitle: "Criterion 5.2 — Placement & Higher Studies",
      icon: "📋",
      isPrimary: true,
      reportType: ReportType.naac,
    ),
    Report(
      title: "Placement Summary",
      subtitle: "Comprehensive placement analytics • PDF",
      icon: "📄",
      reportType: ReportType.placementSummary,
    ),
    Report(
      title: "Skill Gap Analysis",
      subtitle: "AI-powered skill analysis • PDF",
      icon: "📊",
      reportType: ReportType.skillGapAnalysis,
    ),
    Report(
      title: "Company Drive Report",
      subtitle: "Drive performance metrics • PDF",
      icon: "📄",
      reportType: ReportType.companyDrive,
    ),
    Report(
      title: "Department Readiness",
      subtitle: "Department-wise assessment • PDF",
      icon: "📈",
      reportType: ReportType.departmentReadiness,
    ),
  ];

  /// Get download state for a specific report
  bool isDownloading(String reportTitle) {
    return _downloadingStates[reportTitle] ?? false;
  }

  /// Download a specific report
  Future<bool> downloadReport(String reportTitle, String collegeName) async {
    try {
      // Find the report
      final report = reports.firstWhere((r) => r.title == reportTitle);

      // Set downloading state
      _downloadingStates[reportTitle] = true;
      notifyListeners();

      AppLogger.info(_tag, 'Starting download for: $reportTitle');

      // Generate and download the report
      final success = await ReportService.generateAndDownloadReport(
        reportType: report.reportType!,
        collegeName: collegeName,
      );

      // Clear downloading state
      _downloadingStates[reportTitle] = false;
      notifyListeners();

      if (success) {
        AppLogger.info(_tag, 'Report downloaded successfully: $reportTitle');
      } else {
        AppLogger.error(_tag, 'Failed to download report: $reportTitle');
      }

      return success;
    } catch (e, st) {
      AppLogger.error(_tag, 'Error downloading report: $reportTitle', e, st);

      // Clear downloading state on error
      _downloadingStates[reportTitle] = false;
      notifyListeners();

      return false;
    }
  }

  /// Get report description for UI
  String getReportDescription(ReportType reportType) {
    return ReportService.getReportDescription(reportType);
  }

  /// Get estimated file size for UI
  String getEstimatedFileSize(ReportType reportType) {
    return ReportService.getEstimatedFileSize(reportType);
  }

  /// Debug method to test PDF generation
  Future<void> debugPdfGeneration() async {
    try {
      AppLogger.info(_tag, 'Debug: Testing PDF generation...');

      final pdfBytes = await PdfGeneratorService.generateReport(
        reportType: ReportType.departmentReadiness,
        collegeName: 'Debug College',
        reportData: {
          'test': 'debug data',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      AppLogger.info(
        _tag,
        'Debug: PDF generated, size: ${pdfBytes.length} bytes',
      );

      if (pdfBytes.isEmpty) {
        AppLogger.error(_tag, 'Debug: PDF bytes are empty!');
      } else {
        AppLogger.info(_tag, 'Debug: PDF generation successful');
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Debug: PDF generation failed', e, st);
    }
  }
}
