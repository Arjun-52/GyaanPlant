import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/report_model.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/report_type.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/report_service.dart';
import 'package:gyaanplant/core/utils/helpers.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/data/services/api_service.dart';

class ReportsViewModel extends ChangeNotifier {
  bool _disposed = false;
  final Set<ReportType> _downloadingReports = {};
  String collegeName = "Loading...";

  Set<ReportType> get downloadingReports => _downloadingReports;

  bool isDownloading(ReportType type) => _downloadingReports.contains(type);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  /// Initialize and fetch the college name dynamically
  void initialize() {
    fetchCollegeName();
  }

  /// Fetch college name dynamically from user profile
  Future<void> fetchCollegeName() async {
    AppLogger.info('ReportsViewModel', 'Fetching college name...');
    try {
      final userResult = await ApiService().auth.getCurrentUser();
      if (userResult.isSuccess && userResult.data != null) {
        final user = userResult.data!;
        final college = user.college;
        if (college != null) {
          if (college.name != null && college.name!.isNotEmpty) {
            collegeName = college.name!;
          } else if (college.id != null) {
            // Fetch complete college details using the ID
            final collegeResult = await ApiService().college.getCollegeById(college.id!);
            if (collegeResult.isSuccess && collegeResult.data != null) {
              final collegeData = collegeResult.data!;
              if (collegeData is Map<String, dynamic> && collegeData.containsKey('name')) {
                collegeName = collegeData['name'] ?? "Unknown College";
              } else {
                collegeName = "Unknown College";
              }
            } else {
              collegeName = "Unknown College";
            }
          } else {
            collegeName = "Unknown College";
          }
        } else {
          collegeName = "Unknown College";
        }
      } else {
        collegeName = "Unknown College";
      }
    } catch (e, st) {
      AppLogger.error('ReportsViewModel', 'Failed to fetch college name', e, st);
      collegeName = "Unknown College";
    }
    notifyListeners();
  }

  /// Generate and download a report, managing loading state and showing feedback toast
  Future<void> downloadReport(Report report, BuildContext context) async {
    if (_downloadingReports.contains(report.type)) {
      return;
    }

    _downloadingReports.add(report.type);
    notifyListeners();

    // Show initial info Toast
    Helpers.showInfoSnackBar(context, "Generating ${report.title} PDF...");

    try {
      final success = await ReportService.generateAndDownloadReport(
        reportType: report.type,
        collegeName: collegeName,
      );

      if (success) {
        Helpers.showSuccessSnackBar(context, "${report.title} downloaded successfully!");
      } else {
        Helpers.showErrorSnackBar(context, "Failed to download ${report.title}.");
      }
    } catch (e, st) {
      AppLogger.error('ReportsViewModel', 'Error during report download', e, st);
      Helpers.showErrorSnackBar(context, "Error downloading ${report.title}.");
    } finally {
      _downloadingReports.remove(report.type);
      notifyListeners();
    }
  }

  final List<Report> reports = [
    Report(
      title: "Generate NAAC Report",
      subtitle: "Criterion 5.2 — Placement & Higher Studies",
      icon: "📋",
      isPrimary: true,
      type: ReportType.naac,
    ),
    Report(
      title: "Monthly Placement Summary",
      subtitle: "Feb 2026 • PDF",
      icon: "📄",
      type: ReportType.placementSummary,
    ),
    Report(
      title: "Student Skill Gap Analysis",
      subtitle: "Q1 2026 • Excel",
      icon: "📊",
      type: ReportType.skillGapAnalysis,
    ),
    Report(
      title: "Drive Outcome Report — TCS",
      subtitle: "Jan 2026 • PDF",
      icon: "📄",
      type: ReportType.companyDrive,
    ),
    Report(
      title: "Department-wise Readiness",
      subtitle: "Feb 2026 • PDF",
      icon: "📈",
      type: ReportType.departmentReadiness,
    ),
    Report(
      title: "NAAC Q2 Placement Data",
      subtitle: "Oct 2025 • PDF",
      icon: "📁",
      type: ReportType.naac,
    ),
  ];
}
