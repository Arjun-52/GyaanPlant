import 'package:flutter/material.dart';

class StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatBox(this.value, this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        /// 🔥 DARK GREEN GRADIENT BG
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2A20), Color(0xFF0A1F18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        /// 🔥 SOFT BORDER
        border: Border.all(color: color.withOpacity(0.3)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 👈 LEFT ALIGN
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
