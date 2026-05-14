import 'package:flutter/material.dart';

class TotalEarningsCard extends StatelessWidget {
  const TotalEarningsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0033), Color(0xFF0D001F)],
        ),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            "TOTAL EARNED",
            style: TextStyle(color: Colors.white38, letterSpacing: 1),
          ),

          const SizedBox(height: 10),

          const Text(
            "₹28,400",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB388FF),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Since joining · 24 sessions",
            style: TextStyle(color: Colors.white38),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// this month chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF16C47F).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "↑ ₹9,600 this month",
                  style: TextStyle(color: Color(0xFF16C47F)),
                ),
              ),

              const SizedBox(width: 10),

              /// payout chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "80% payout rate",
                  style: TextStyle(color: Color(0xFFB388FF)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
