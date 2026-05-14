import 'package:flutter/material.dart';
import 'parent_report_card.dart';

class ParentReportSection extends StatelessWidget {
  const ParentReportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        /// TITLE
        Text(
          "Parent Report Cards",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12),

        /// CARDS
        ParentReportCard(
          name: "Arjun Kumar's Parents",
          subtitle: "Sent 2 days ago",
        ),

        SizedBox(height: 10),

        ParentReportCard(
          name: "Sneha Murthy's Parents",
          subtitle: "Sent 2 days ago",
        ),
      ],
    );
  }
}
