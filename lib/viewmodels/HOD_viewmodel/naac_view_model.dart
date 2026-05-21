import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/HOD_models/naac_model.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/report_service.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/report_type.dart';
import 'package:gyaanplant/core/utils/helpers.dart';

class NaacViewModel extends ChangeNotifier {
  static const _tag = 'NaacViewModel';

  NaacModel? naac;
  bool isLoading = false;
  bool isLoaded = false;
  String? errorMessage;
  bool _disposed = false;

  String collegeName = 'Unknown College';
  bool isGeneratingReport = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> fetchNaac() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      try {
        final response = await ApiService().auth.getCurrentUser();
        if (response.success && response.data != null) {
          collegeName = response.data!.college?.name ?? 'Unknown College';
        }
      } catch (e) {
        AppLogger.warning(_tag, 'Failed to fetch user college name: $e');
      }

      // TODO: replace with real API call
      await Future.delayed(const Duration(seconds: 1));

      naac = NaacModel(
        grade: 'A+',
        validTill: 2028,
        criteria: [
          NaacCriterion(title: 'Curricular Aspects', score: 3.4),
          NaacCriterion(title: 'Teaching & Learning', score: 3.6),
          NaacCriterion(title: 'Research & Innovation', score: 3.2),
          NaacCriterion(title: 'Infrastructure', score: 3.5),
          NaacCriterion(title: 'Student Support (Placement)', score: 3.8),
          NaacCriterion(title: 'Governance', score: 3.3),
        ],
      );
      isLoaded = true;
      AppLogger.info(_tag, 'NAAC data loaded');
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to load NAAC data', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateNaacReport(BuildContext context) async {
    if (isGeneratingReport) return;
    isGeneratingReport = true;
    notifyListeners();

    Helpers.showInfoSnackBar(context, "Generating Full NAAC Report...");
    try {
      final success = await ReportService.generateAndDownloadReport(
        reportType: ReportType.naac,
        collegeName: collegeName,
      );
      if (context.mounted) {
        if (success) {
          Helpers.showSuccessSnackBar(context, "NAAC Report generated successfully!");
        } else {
          Helpers.showErrorSnackBar(context, "Failed to generate NAAC Report.");
        }
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Error generating NAAC Report', e, st);
      if (context.mounted) {
        Helpers.showErrorSnackBar(context, "Error generating report: $e");
      }
    } finally {
      isGeneratingReport = false;
      notifyListeners();
    }
  }
}
