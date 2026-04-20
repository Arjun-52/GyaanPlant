import 'package:flutter/material.dart';

class NaacReportCard extends StatelessWidget {
  final VoidCallback onTap;

  const NaacReportCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        gradient: const LinearGradient(
          colors: [Color(0xFF0F3B2E), Color(0xFF0A241D)],
        ),

        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
      ),

      child: Row(
        children: [
          /// ICON
          const Text("📊", style: TextStyle(fontSize: 24)),

          const SizedBox(width: 12),

          /// TEXT
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "One-Click NAAC Report",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Auto-fills Q1–Q5 placement data instantly",
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),

          /// BUTTON
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
