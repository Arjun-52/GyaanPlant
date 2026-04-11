import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  Widget box(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF114235),
            Color(0xFF0D2F24),
            Color(0xFF0A241D),
            Color(0xFF071C16),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: box("71", "Readiness Score", Colors.green)),
            const SizedBox(width: 10),
            Expanded(child: box("24", "Tests Completed", Colors.green)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: box("142", "Hours Learned", Colors.green)),
            const SizedBox(width: 10),
            Expanded(child: box("14", "Day Streak", Colors.orange)),
          ],
        ),
      ],
    );
  }
}
