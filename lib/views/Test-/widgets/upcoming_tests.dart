import 'package:flutter/material.dart';
import 'test_pack_card.dart';

class UpcomingTests extends StatelessWidget {
  const UpcomingTests({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Upcoming Test Packs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 14),

        TestPackCard(
          "TCS NQT Full Mock",
          "3 rounds · 90 min",
          "₹299",
          Color(0xFF00C853), // green
        ),

        TestPackCard(
          "Infosys InfyTQ Prep",
          "Aptitude + Coding",
          "₹249",
          Color(0xFFFFA726), // orange
        ),

        TestPackCard(
          "Wipro NLTH Pack",
          "4 sections · 120 min",
          "₹279",
          Color(0xFF42A5F5), // blue
        ),
      ],
    );
  }
}
