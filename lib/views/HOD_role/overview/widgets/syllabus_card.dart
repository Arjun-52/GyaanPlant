import 'package:flutter/material.dart';

class SyllabusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int progress;

  const SyllabusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        color: const Color(0xFF0F3D34),

        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),

      child: Row(
        children: [
          ///  ICON
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "📐",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),

                const SizedBox(height: 8),

                ///PROGRESS BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 10,
                    minHeight: 6,
                    color: const Color(0xFF00C853),
                    backgroundColor: Colors.white.withOpacity(0.08),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.blueAccent.withValues(alpha: 0.6),
              ),
              color: Colors.blueAccent.withValues(alpha: 0.1),
            ),
            child: const Text(
              "Map",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
