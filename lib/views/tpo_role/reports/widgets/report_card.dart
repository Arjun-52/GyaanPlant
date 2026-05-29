import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/report_model.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/reports_viewmodel.dart';

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ReportsViewModel>(context);
    final isDownloading = vm.isDownloading(report.type);

    final String fileType = report.subtitle.toLowerCase().contains("excel")
        ? "EXCEL"
        : report.subtitle.toLowerCase().contains("archive")
            ? "ZIP"
            : "PDF";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C221B), Color(0xFF05100C)],
        ),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🟢 FILE ICON AND BADGE (LEFT)
          _buildFileIconBadge(fileType),

          const SizedBox(width: 12),

          /// 🟢 CENTER DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  report.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      report.subtitle.split("•").first.trim(),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFileTypeChip(fileType),
                  ],
                ),
              ],
            ),
          ),

          /// 🟢 DOWNLOAD OR STATUS TRIGGER (RIGHT)
          _buildDownloadButton(vm, isDownloading, context),
        ],
      ),
    );
  }

  /// 🔷 FILE ICON BADGE WIDGET
  Widget _buildFileIconBadge(String fileType) {
    IconData iconData = Icons.picture_as_pdf;
    List<Color> gradientColors = [const Color(0xFFE53935), const Color(0xFFB71C1C)]; // Red gradient for PDF

    if (fileType == "EXCEL") {
      iconData = Icons.table_chart;
      gradientColors = [const Color(0xFF43A047), const Color(0xFF1B5E20)]; // Green gradient for Excel
    } else if (fileType == "ZIP") {
      iconData = Icons.folder_zip;
      gradientColors = [const Color(0xFFFFB300), const Color(0xFFFF6F00)]; // Orange/amber gradient for Zip
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Center(
        child: Icon(
          iconData,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// 🔷 FILE TYPE CHIP TAG WIDGET
  Widget _buildFileTypeChip(String fileType) {
    Color textColor = const Color(0xFFE53935);
    Color bgColor = const Color(0xFFE53935).withOpacity(0.1);

    if (fileType == "EXCEL") {
      textColor = const Color(0xFF00E676);
      bgColor = const Color(0xFF00E676).withOpacity(0.1);
    } else if (fileType == "ZIP") {
      textColor = const Color(0xFFFFB300);
      bgColor = const Color(0xFFFFB300).withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        fileType,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 🔷 PREMIUM DOWNLOAD CIRCULAR TRIGGER
  Widget _buildDownloadButton(ReportsViewModel vm, bool isDownloading, BuildContext context) {
    return InkWell(
      onTap: isDownloading ? null : () => vm.downloadReport(report, context),
      borderRadius: BoxShape.circle == null ? BorderRadius.circular(100) : null,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDownloading
              ? Colors.greenAccent.withOpacity(0.05)
              : const Color(0xFF00C853).withOpacity(0.15),
          border: Border.all(
            color: isDownloading
                ? Colors.greenAccent.withOpacity(0.2)
                : const Color(0xFF00C853).withOpacity(0.4),
            width: 1.0,
          ),
          boxShadow: isDownloading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Center(
          child: isDownloading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                  ),
                )
              : const Icon(
                  Icons.download,
                  color: Color(0xFF00E676),
                  size: 18,
                ),
        ),
      ),
    );
  }
}
