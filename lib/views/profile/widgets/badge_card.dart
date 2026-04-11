import 'package:flutter/material.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2A4A), // ✅ dark blue (no gradient)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF123A63)),
      ),
      child: Row(
        children: [
          ///  Icon box
          const Text("💼", style: TextStyle(fontSize: 20)),

          const SizedBox(width: 12),

          ///  Text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Share GyaanPlant Badge",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Let recruiters discover your profile",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          ///  Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4DA3FF), Color(0xFF2F80ED)],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              children: [
                Text(
                  "Share",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
