import 'dart:typed_data';
import 'package:gyaanplant/views/tpo_role/reports/services/pdf_generator_service.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/download_handler.dart';
import 'package:gyaanplant/models/tpo_role_models/report_model.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/report_type.dart';

/// Simple test to debug PDF generation issues
class PdfTest {
  static const _tag = 'PdfTest';

  static Future<void> testPdfGeneration() async {
    try {
      AppLogger.info(_tag, 'Starting PDF generation test...');

      // Test NAAC report generation
      final pdfBytes = await PdfGeneratorService.generateReport(
        reportType: ReportType.departmentReadiness,
        collegeName: 'Test College',
        reportData: {'test': 'data', 'score': 85},
      );

      AppLogger.info(_tag, 'PDF generation test completed');
      AppLogger.info(_tag, 'PDF bytes size: ${pdfBytes.length}');

      if (pdfBytes.isEmpty) {
        AppLogger.error(_tag, 'PDF bytes are empty!');
      } else {
        AppLogger.info(_tag, 'PDF generation successful');
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'PDF generation test failed', e, st);
    }
  }

  static Future<void> testDownloadHandler() async {
    try {
      AppLogger.info(_tag, 'Starting download handler test...');

      // Test with dummy data
      final dummyBytes = [1, 2, 3, 4, 5]; // Small test data

      final success = await DownloadHandler.downloadAndOpenPdf(
        pdfBytes: Uint8List.fromList(dummyBytes),
        fileName: 'test_report',
        reportType: 'Test Report',
      );

      AppLogger.info(_tag, 'Download handler test completed');
      AppLogger.info(_tag, 'Success: $success');
    } catch (e, st) {
      AppLogger.error(_tag, 'Download handler test failed', e, st);
    }
  }
}
