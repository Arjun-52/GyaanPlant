import 'package:flutter/material.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/report_service.dart';
import 'package:gyaanplant/models/tpo_role_models/report_model.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/report_type.dart';

void main() async {
  print('Testing PDF download functionality...');
  
  try {
    // Test the download functionality directly
    final success = await ReportService.generateAndDownloadReport(
      reportType: ReportType.departmentReadiness,
      collegeName: 'Test College',
    );
    
    if (success) {
      print('✅ Download test PASSED');
    } else {
      print('❌ Download test FAILED');
    }
  } catch (e, st) {
    print('❌ Exception: $e');
  }
}
