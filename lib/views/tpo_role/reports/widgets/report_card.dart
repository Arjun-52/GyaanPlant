import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/models/tpo_role_models/report_model.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/reports_viewmodel.dart';

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsViewModel>(
      builder: (context, viewModel, child) {
        final isDownloading = viewModel.isDownloading(report.title);

        return GestureDetector(
          onTap: isDownloading
              ? null
              : () => _handleDownload(context, viewModel),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: report.isPrimary ? 0 : 3),
            padding: EdgeInsets.all(report.isPrimary ? 8 : 9),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),

              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: report.isPrimary
                    ? [Color(0xFF0F3B2E), Color(0xFF0A241D)]
                    : [Color(0xFF0C2A22), Color(0xFF071E17)],
              ),

              border: Border.all(
                color: report.isPrimary
                    ? Colors.greenAccent.withValues(alpha: 0.3)
                    : Colors.green.withValues(alpha: 0.1),
                width: report.isPrimary ? 1.2 : 0.8,
              ),

              boxShadow: report.isPrimary
                  ? [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),

            ///  THIS CONTROLS HEIGHT DIFFERENCE
            child: SizedBox(
              height: report.isPrimary ? 70 : 70,
              child: Row(
                children: [
                  /// ICON
                  Text(
                    report.icon,
                    style: TextStyle(fontSize: report.isPrimary ? 26 : 22),
                  ),

                  const SizedBox(width: 12),

                  /// TEXT
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: report.isPrimary ? 16 : 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.subtitle,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: report.isPrimary ? 12 : 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// DOWNLOAD BUTTON
                  Container(
                    padding: EdgeInsets.all(report.isPrimary ? 12 : 10),
                    decoration: BoxDecoration(
                      color: isDownloading
                          ? Colors.grey.withOpacity(0.3)
                          : report.isPrimary
                          ? const Color(0xFF00C853)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isDownloading
                        ? SizedBox(
                            width: report.isPrimary ? 20 : 18,
                            height: report.isPrimary ? 20 : 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                report.isPrimary ? Colors.black : Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.download,
                            color: report.isPrimary
                                ? Colors.black
                                : Colors.white70,
                            size: report.isPrimary ? 20 : 18,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleDownload(BuildContext context, ReportsViewModel viewModel) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Generating report...',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00C853),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Start download
      final success = await viewModel.downloadReport(
        report.title,
        'GRIET Hyderabad', // TODO: Get from college data
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Report downloaded successfully',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF00C853),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Failed to generate report',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'An error occurred',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
