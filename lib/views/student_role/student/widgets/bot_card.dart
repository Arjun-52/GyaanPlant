import 'package:flutter/material.dart';

class BotCard extends StatelessWidget {
  const BotCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        // ✅ Background gradient (matches your UI)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B2F25), Color(0xFF041A14)],
        ),

        // ✅ Subtle border
        border: Border.all(color: const Color(0xFF1FA463), width: 1),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Top Row (icon + name)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00C853),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Colors.black,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                "GyaanBot",
                style: TextStyle(
                  color: Color(0xFF00C853),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 Description text
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
              children: [
                TextSpan(text: "You're "),
                TextSpan(
                  text: "13 points away",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: " from MNC-ready status.\n"),
                TextSpan(text: "Focus on "),
                TextSpan(
                  text: "Data Structures",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text:
                      " today — it’s your weakest subject and TCS tests it heavily in Round 2.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
