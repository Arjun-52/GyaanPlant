import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/report_model.dart';

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              ? Colors.greenAccent.withOpacity(0.3)
              : Colors.green.withOpacity(0.1),
          width: report.isPrimary ? 1.2 : 0.8,
        ),

        boxShadow: report.isPrimary
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.15),
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
                color: report.isPrimary
                    ? const Color(0xFF00C853)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.download,
                color: report.isPrimary ? Colors.black : Colors.white70,
                size: report.isPrimary ? 20 : 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
