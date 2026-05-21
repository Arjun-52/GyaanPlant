import 'package:flutter/material.dart';

/// Renders a dynamic completion progress indicator.
class ProgressCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final double percent;

  const ProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1FA463).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Course Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$completedCount of $totalCount completed (${(percent * 100).round()}%)",
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Custom Linear Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: const Color(0xFF102821),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
            ),
          ),
        ],
      ),
    );
  }
}
