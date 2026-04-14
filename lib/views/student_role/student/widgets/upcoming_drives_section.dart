import 'package:flutter/material.dart';

class UpcomingDrivesSection extends StatelessWidget {
  final List drives;

  const UpcomingDrivesSection({super.key, required this.drives});

  @override
  Widget build(BuildContext context) {
    // ❌ Empty state
    if (drives.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Upcoming Drives",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text("No upcoming drives", style: TextStyle(color: Colors.white54)),
        ],
      );
    }

    // ✅ Data exists
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming Drives",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Column(
          children: drives.map((drive) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: const Color(0xFF0F2A22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1FA463)),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// 🔹 Company Name
                  Text(
                    drive['company'] ?? "Company",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  /// 🔹 Date
                  Text(
                    drive['driveDate'] ?? "",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
