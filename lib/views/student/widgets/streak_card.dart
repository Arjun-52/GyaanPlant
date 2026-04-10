import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1A1205),
        border: Border.all(color: const Color(0xFFFFA726)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Fire Icon
          const Text("🔥", style: TextStyle(fontSize: 28)),

          const SizedBox(width: 12),

          // 🔹 Right Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "14-Day Streak!",
                  style: TextStyle(
                    color: Color(0xFFFFA726),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Complete today's task — Day 15 reward: Free Mock Interview",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 12),

                // 🔹 Days Row
                Row(
                  children: [
                    _dayBox("M", true),
                    _dayBox("T", true),
                    _dayBox("W", true),
                    _dayBox("T", true),
                    _dayBox("F", true),
                    _dayBox("S", false),
                    _dayBox("S", false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Day Box Widget
  Widget _dayBox(String day, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: 30,
      height: 30,
      alignment: Alignment.center,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? const Color(0xFFFFA726) : const Color(0xFF2A2A2A),
        border: Border.all(
          color: isActive ? const Color(0xFFFFA726) : Colors.transparent,
        ),
      ),

      child: Text(
        day,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
