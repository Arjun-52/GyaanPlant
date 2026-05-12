import 'package:flutter/material.dart';

class ProgressSectionWidget extends StatelessWidget {
  final double progressPercentage;
  final int completedStages;
  final int totalStages;

  const ProgressSectionWidget({
    super.key,
    required this.progressPercentage,
    required this.completedStages,
    required this.totalStages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F5A4A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Roadmap Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${progressPercentage.round()}%',
                style: const TextStyle(
                  color: Color(0xFF00C853),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$completedStages of $totalStages stages completed',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
