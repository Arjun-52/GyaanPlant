import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  Widget statBox(String value, String label, Color color) {
    return Container(
      height: 80, // 👈 FIX: force equal height
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green, width: 0.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: statBox("12", "Correct", Colors.green)),
        const SizedBox(width: 10),

        Expanded(child: statBox("3", "Wrong", Colors.red)),
        const SizedBox(width: 10),

        Expanded(child: statBox("5", "Remaining", Colors.blue)),
        const SizedBox(width: 10),

        Expanded(child: statBox("83%", "Accuracy", Colors.orange)),
      ],
    );
  }
}
