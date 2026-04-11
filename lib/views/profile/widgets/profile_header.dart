import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0A241D),
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00C853), width: 2),
            ),
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00C853),
              ),
              alignment: Alignment.center,
              child: const Text(
                "AK",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          "Arjun Kumar",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "GRIET Hyderabad · B.Tech CSE · 2025",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),

        const SizedBox(height: 12),

        // Chips row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip("🏆 Rank #47", Colors.green),
            const SizedBox(width: 8),
            _chip("🔥 14-day streak", Colors.orange),
            const SizedBox(width: 8),
            _chip("📘 3 certs", Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
